# Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-linux-bins-unpatched";
  appId = 4020;
  depotId = 4023;
  manifestId = 1978825540093010308;
  outputHash = "sha256-QWqoAo+niwhu1Ksju/57bRWfMGaAWhphzMUQRoLzmls=";
  meta.license = lib.licenses.unfree;
}