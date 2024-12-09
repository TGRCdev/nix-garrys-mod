# Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-linux-bins-unpatched";
  appId = 4020;
  depotId = 4023;
  manifestId = 6222789010703016116;
  outputHash = "sha256-FbJX5yThqV59ufIB6MVhvVovcg+uw2V5fW5yShnuUdg=";
  meta.license = lib.licenses.unfree;
}