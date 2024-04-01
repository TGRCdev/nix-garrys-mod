{
  buildEnv,
  steam-sdk-redist,
  server-content,
  server-binaries,
  extraPaths ? [],
}: buildEnv {
  name = "garrys-mod-dedicated-server";
  paths = [
    steam-sdk-redist
    server-content
    server-binaries
  ] ++ extraPaths;
}