# Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
{ lib, fetchDepot }:
fetchDepot {
  name = "garrys-mod-dedicated-server-linux-bins-unpatched";
  appId = 4020;
  depotId = 4023;
  manifestId = 7337158995001277286;
  outputHash = "sha256-nUfeEZK3vk3jQMbEn4EgqVOY1vz0GLIulKH1PdNbv30=";
  meta.license = lib.licenses.unfree;
}