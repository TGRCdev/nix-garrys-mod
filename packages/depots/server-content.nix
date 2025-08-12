# Actual game content, does not need fixup
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-content";
  appId = 4020;
  depotId = 4021;
  manifestId = 2107953891666621145;
  outputHash = "sha256-gyGL/xG2oYHSHiCWHi7jICblBLkneLMHFAkWyp9lxws=";
  meta.license = lib.licenses.unfree;
}