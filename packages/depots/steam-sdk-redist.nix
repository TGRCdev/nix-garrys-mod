# steamclient.so
{ lib, fetchDepot }:
fetchDepot {
  name = "steam-sdk-redist";
  appId = 4020;
  depotId = 1006;
  manifestId = 4884950798805348056;
  outputHash = "sha256-IUoZ0JkpisMY4Pzqg3Bi99MhU6IRbBenQJspzq0PRLE=";
  meta.license = lib.licenses.unfreeRedistributable;
}