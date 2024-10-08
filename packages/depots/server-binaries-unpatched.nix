# Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-linux-bins-unpatched";
  appId = 4020;
  depotId = 4023;
  manifestId = 8595942202159102743;
  outputHash = "sha256-ruI7IMJ+XxY3BuVIU9Y+OA+M/DYq5Mt3rX/7yABCbHc=";
  meta.license = lib.licenses.unfree;
}