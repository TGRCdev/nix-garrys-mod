{
  runCommandLocal,
  steam-sdk-redist,
  server-content,
  server-binaries,
  extraPaths ? [],
  name ? "garrys-mod-dedicated-server",
}: runCommandLocal name {
    srcs = [
      steam-sdk-redist
      server-content
      server-binaries
    ] ++ extraPaths;
  } ''
    mkdir $out
    umask u+rw
    for src in $srcs; do
      cp -Rsfv --no-preserve=mode,ownership $src/* $out/
    done
  ''