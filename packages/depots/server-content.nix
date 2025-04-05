# Actual game content, does not need fixup
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-content";
  appId = 4020;
  depotId = 4021;
  manifestId = 6018217738329257558;
  outputHash = "sha256-kGcuqiFQNHFK8AK0KrcVCyHlZXVyjpOnriywvEzPWdY=";
  meta.license = lib.licenses.unfree;
}