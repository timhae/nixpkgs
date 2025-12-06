{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.aria2;
in
{
  port = 9578;
  listenAddress = ":9578";
  extraOpts = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.prometheus-aria2-exporter;
      example = "pkgs.aria2_exporter-fork";
      description = "The package to use for aria2_exporter";
    };

    rpcUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:6800";
      example = "http://aria2.example.com:6800";
      description = "The RPC endpoint of aria2 aria2_exporter should connect to.";
    };

    rpcSecret = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "totallysecretsecret";
      description = "The RPC secret of aria2.";
    };
  };

  serviceOpts = {
    serviceConfig = lib.mkIf cfg.enable {
      # environment = {
      #   ARIA2_EXPORTER_LISTEN_ADDRESS = cfg.listenAddress;
      #   ARIA2_URL = cfg.rpcUrl;
      #   ARIA2_RPC_SECRET = cfg.rpcSecret;
      # };
      ExecStart = "${cfg.package}/bin/aria2_exporter";
      CapabilityBoundingSet = null;
      PrivateUsers = true;
      SystemCallFilter = "@system-service";
    };
  };
}
