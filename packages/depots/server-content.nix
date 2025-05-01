# Actual game content, does not need fixup
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-content";
  appId = 4020;
  depotId = 4021;
  manifestId = 3383899766003270138;
  outputHash = "sha256-lNdqZM/yrJBkwCqVbEMFRVekVzQX6DZUrCeAoEQLJrY=";
  meta.license = lib.licenses.unfree;
}