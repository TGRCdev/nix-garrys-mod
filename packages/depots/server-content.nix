# Actual game content, does not need fixup
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-content";
  appId = 4020;
  depotId = 4021;
  manifestId = 5070358990555268659;
  outputHash = "sha256-kwIYx8bPDBFW6f4YPd9LWlnHydrSh3mVhpW3I92mrWk=";
  meta.license = lib.licenses.unfree;
}