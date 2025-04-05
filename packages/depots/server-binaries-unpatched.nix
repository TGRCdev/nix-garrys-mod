# Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-linux-bins-unpatched";
  appId = 4020;
  depotId = 4023;
  manifestId = 2498902166196267651;
  outputHash = "sha256-6FZQ3SgEPqc5GINo40g6iNRNoySd/McfgrU1Qldl5eg=";
  meta.license = lib.licenses.unfree;
}