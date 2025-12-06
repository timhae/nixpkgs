{
  system ? builtins.currentSystem,
  config ? { },
  pkgs ? import ../.. { inherit system config; },
}:

let
  inherit (import ../lib/testing-python.nix { inherit system pkgs; }) makeTest;
  inherit (pkgs.lib)
    concatStringsSep
    maintainers
    mapAttrs
    mkMerge
    removeSuffix
    replaceStrings
    singleton
    splitString
    makeBinPath
    ;

  /*
    * The attrset `exporterTests` contains one attribute
    * for each exporter test. Each of these attributes
    * is expected to be an attrset containing:
    *
    *  `exporterConfig`:
    *    this attribute set contains config for the exporter itself
    *
    *  `exporterTest`
    *    this attribute set contains test instructions
    *
    *  `metricProvider` (optional)
    *    this attribute contains additional machine config
    *
    *  `nodeName` (optional)
    *    override an incompatible testnode name
    *
    *  Example:
    *    exporterTests.<exporterName> = {
    *      exporterConfig = {
    *        enable = true;
    *      };
    *      metricProvider = {
    *        services.<metricProvider>.enable = true;
    *      };
    *      exporterTest = ''
    *        wait_for_unit("prometheus-<exporterName>-exporter.service")
    *        wait_for_open_port(1234)
    *        succeed("curl -sSf 'localhost:1234/metrics'")
    *      '';
    *    };
    *
    *  # this would generate the following test config:
    *
    *    nodes.<exporterName> = {
    *      services.prometheus.<exporterName> = {
    *        enable = true;
    *      };
    *      services.<metricProvider>.enable = true;
    *    };
    *
    *    testScript = ''
    *      <exporterName>.start()
    *      <exporterName>.wait_for_unit("prometheus-<exporterName>-exporter.service")
    *      <exporterName>.wait_for_open_port(1234)
    *      <exporterName>.succeed("curl -sSf 'localhost:1234/metrics'")
    *      <exporterName>.shutdown()
    *    '';
  */

  exporterTests = {
    aria2 =
      let
        rpcSecret = "supersecret";
      in
      {
        exporterConfig = {
          inherit rpcSecret;
          enable = true;
          listenAddress = ":9587";
        };
        metricProvider = {
          environment.etc."aria2Rpc".text = "supersecret";
          services.aria2 = {
            rpcSecretFile = "/etc/aria2Rpc";
            enable = true;
            openPorts = true;
            settings.rpc-listen-all = true;
          };
        };
        exporterTest = ''
          wait_for_unit("aria2.service")
          wait_for_open_port(3551)
          wait_for_unit("prometheus-aria2-exporter.service")
          wait_for_open_port(9578)
          succeed("curl -sSf http://localhost:9578/metrics | grep 'apcupsd_info'")
        '';
      };
  };
in
mapAttrs (
  exporter: testConfig:
  (makeTest (
    let
      nodeName = testConfig.nodeName or exporter;

    in
    {
      name = "prometheus-${exporter}-exporter";

      nodes.${nodeName} = mkMerge [
        {
          services.prometheus.exporters.${exporter} = testConfig.exporterConfig;
        }
        testConfig.metricProvider or { }
      ];

      testScript = ''
        ${nodeName}.start()
        ${concatStringsSep "\n" (
          map (
            line:
            if
              builtins.any (b: b) [
                (builtins.match "^[[:space:]]*$" line != null)
                (builtins.substring 0 1 line == "#")
                (builtins.substring 0 1 line == " ")
                (builtins.substring 0 1 line == ")")
              ]
            then
              line
            else
              "${nodeName}.${line}"
          ) (splitString "\n" (removeSuffix "\n" testConfig.exporterTest))
        )}
        ${nodeName}.shutdown()
      '';

      meta.maintainers = [ ];
    }
  ))
) exporterTests
