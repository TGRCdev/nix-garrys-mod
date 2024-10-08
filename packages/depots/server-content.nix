# Actual game content, does not need fixup
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-content";
  appId = 4020;
  depotId = 4021;
  manifestId = 1458285547022159422;
  outputHash = "sha256-xvyZdFZftv+ydUtaKriTmr0r8e2kmUvdP49Q02xROTo=";
  meta.license = lib.licenses.unfree;
}