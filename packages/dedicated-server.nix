{
  symlinkJoin,
  steam-sdk-redist,
  server-content,
  server-binaries,
}: symlinkJoin {
  name = "garrys-mod-dedicated-server";
  paths = [
    steam-sdk-redist
    server-content
    server-binaries
  ];
}