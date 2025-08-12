# steamclient.so
{ lib, fetchDepot }:
fetchDepot {
  name = "steam-sdk-redist";
  appId = 4020;
  depotId = 1006;
  manifestId = 5587033981095108078;
  outputHash = "sha256-CjrVpq5ztL6wTWIa63a/4xHM35DzgDR/O6qVf1YV5xw=";
  meta.license = lib.licenses.unfreeRedistributable;
}