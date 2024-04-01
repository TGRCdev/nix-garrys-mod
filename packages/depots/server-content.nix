# Actual game content, does not need fixup
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-content";
  appId = 4020;
  depotId = 4021;
  manifestId = 5179858603377479094;
  outputHash = "sha256-rUiQ+xwaw+meBTVFwBFY8ZjOCOOvvdI0vjX9p2ZgsSs=";
  meta.license = lib.licenses.unfree;
}