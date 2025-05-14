# Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-linux-bins-unpatched";
  appId = 4020;
  depotId = 4023;
  manifestId = 4682560487321813702;
  outputHash = "sha256-14uKmCMUM/SchfuS52GcocmRNoSE3VIvMRwUTIvCRRg=";
  meta.license = lib.licenses.unfree;
}