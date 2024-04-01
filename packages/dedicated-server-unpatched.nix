{
  symlinkJoin,
  steam-sdk-redist,
  server-content,
  server-binaries-unpatched,
}: symlinkJoin {
  name = "garrys-mod-dedicated-server-unpatched";
  paths = [
    steam-sdk-redist
    server-content
    server-binaries-unpatched
  ];
}