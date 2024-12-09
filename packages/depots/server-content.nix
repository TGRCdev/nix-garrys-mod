# Actual game content, does not need fixup
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-content";
  appId = 4020;
  depotId = 4021;
  manifestId = 7875986024096193408;
  outputHash = "sha256-AYsRpRjZgQ/r8Nmfwj3tv9tRoV1BdMBdLnOqKaoATKM=";
  meta.license = lib.licenses.unfree;
}