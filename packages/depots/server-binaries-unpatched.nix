# Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-linux-bins-unpatched";
  appId = 4020;
  depotId = 4023;
  manifestId = 2423163156158381622;
  outputHash = "sha256-6o11aSORuEWe+CRSmBrpjWhnmqWpDepRX7wOaEXfO3s=";
  meta.license = lib.licenses.unfree;
}