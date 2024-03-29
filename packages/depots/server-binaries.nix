# Fixup and patch binaries to work without steam-run
{
  pkgs,
  pkgsi686Linux,
  stdenvNoCC,
  steamPackages,
  fetchDepot,
}: stdenvNoCC.mkDerivation {
  name = "garrys-mod-dedicated-server-linux-bins";
  src = pkgs.callPackage ./server-binaries-unpatched.nix { inherit fetchDepot; };

  buildInputs = [
    steamPackages.steam-runtime
  ];
  nativeBuildInputs = [
    pkgsi686Linux.autoPatchelfHook
  ];

  buildPhase = ''
    cp -r $src $out

    # This one file has costed me a month and a half of debugging
    chmod +w $out
    echo 4000 > $out/steam_appid.txt
  '';

  preFixupPhases = [ "autoPatchelfPathsPhase" ];
  # Find dependencies from the runtime and link them
  autoPatchelfPathsPhase = ''
    addAutoPatchelfSearchPath ${steamPackages.steam-runtime}/usr/lib/i386-linux-gnu/
    addAutoPatchelfSearchPath ${steamPackages.steam-runtime}/lib/i386-linux-gnu/
    addAutoPatchelfSearchPath $out/bin
  '';
  # AFAIK these aren't needed for the headless server
  autoPatchelfIgnoreMissingDeps = [
    "libtier0.so"
    "libvstdlib.so"
  ];
}