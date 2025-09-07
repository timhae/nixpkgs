{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "aria2-exporter";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "timhae";
    repo = "aria2_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tnUVKAZnoynCJNgs8n6EcQ5vMZyHjsgnHg/xpBTJ3Qc=";
  };

  vendorHash = "sha256-Ke4oqPqD9shMBmbz1MvOMpm24Y4b+uU3Avx108M9NeM=";

  doCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Prometheus exporter for Aria2";
    homepage = "https://github.com/timhae/aria2_exporter";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.timhae ];
    mainProgram = "deluge-exporter";
  };
})
