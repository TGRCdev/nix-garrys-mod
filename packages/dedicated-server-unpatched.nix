{
  buildEnv,
  steam-sdk-redist,
  server-content,
  server-binaries-unpatched,
  extraPaths ? [],
}: buildEnv {
  name = "garrys-mod-dedicated-server-unpatched";
  paths = [
    steam-sdk-redist
    server-content
    server-binaries-unpatched
  ] ++ extraPaths;
}