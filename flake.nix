{
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    fetchDepot = (pkgs.callPackage ./depots {}).fetchDepot;
  in {
    packages.${system}.garrys-mod = rec {
      steam-sdk-redist = fetchDepot {
        name = "steam-sdk-redist";
        appId = 4020;
        depotId = 1006;
        manifestId = 4884950798805348056;
        outputHash = "sha256-IUoZ0JkpisMY4Pzqg3Bi99MhU6IRbBenQJspzq0PRLE=";
      };
      dedicated-server-content = fetchDepot {
        name = "dedicated-server-content";
        appId = 4020;
        depotId = 4021;
        manifestId = 7918776424147734184;
        outputHash = "sha256-viuPi6ou5EJRqkFW9jpFm8KZNz9ROjivWx1XBQjRJZc=";
      };
      dedicated-server-linux = let
        runtimeLibs = with pkgs.pkgsi686Linux; [
          gcc-unwrapped.lib
          ncurses5
          gperftools
        ];
      in pkgs.pkgsi686Linux.stdenv.mkDerivation {
        name = "dedicated-server-linux";
        src = fetchDepot {
          name = "dedicated-server-linux-unpatched";
          appId = 4020;
          depotId = 4023;
          manifestId = 3728493952843195777;
          outputHash = "sha256-cwyJzU5+xA8bcsuOBXNbR/bNXAQNVXxEfv6DLviHq6I=";
        };
        buildInputs = runtimeLibs;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          mkdir $out
          cp -r $src/* $out
        '';
        preFixup = ''
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/srcds_linux
        '';
        postFixup = ''
          wrapProgram $out/srcds_linux --set LD_LIBRARY_PATH "$out:$out/bin:${pkgs.lib.makeLibraryPath runtimeLibs}"
        '';
      };
      default = pkgs.symlinkJoin {
        name = "garrys-mod-server";
        paths = [
          steam-sdk-redist
          dedicated-server-content
          dedicated-server-linux
        ];
      };
    };
  };
}