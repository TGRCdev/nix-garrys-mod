# steamclient.so
{ lib, fetchDepot }:
fetchDepot {
  name = "steam-sdk-redist";
  appId = 4020;
  depotId = 1006;
  manifestId = 7138471031118904166;
  outputHash = "sha256-OtPI1kAx6+9G09IEr2kYchyvxlPl3rzx/ai/xEVG4oM=";
  meta.license = lib.licenses.unfreeRedistributable;
}