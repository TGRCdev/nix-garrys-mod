{
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    fetchDepot = (pkgs.callPackage ./depot.nix {}).fetchDepot;
    stdenv = pkgs.stdenvNoCC;
  in {
    packages.${system} = rec {
      # steamclient.so
      steam-sdk-redist = stdenv.mkDerivation {
        name = "steam-sdk-redist";
        src = fetchDepot {
          name = "steam-sdk-redist-src";
          appId = 4020;
          depotId = 1006;
          manifestId = 4884950798805348056;
          outputHash = "sha256-IUoZ0JkpisMY4Pzqg3Bi99MhU6IRbBenQJspzq0PRLE=";
        };

        buildPhase = ''
          mkdir $out
          cp -r $src/* $out
        '';
      };

      garrys-mod = rec {
        # Actual game content, does not need fixup
        dedicated-server-content = fetchDepot {
          name = "dedicated-server-content";
          appId = 4020;
          depotId = 4021;
          manifestId = 5179858603377479094;
          outputHash = "sha256-rUiQ+xwaw+meBTVFwBFY8ZjOCOOvvdI0vjX9p2ZgsSs=";
        };

        # Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
        dedicated-server-linux-bins = stdenv.mkDerivation {
          name = "garrys-mod-dedicated-server-linux-bins";
          src = fetchDepot {
            name = "garrys-mod-dedicated-server-linux-bins-unpatched";
            appId = 4020;
            depotId = 4023;
            manifestId = 1978825540093010308;
            outputHash = "sha256-QWqoAo+niwhu1Ksju/57bRWfMGaAWhphzMUQRoLzmls=";
          };

          buildInputs = [
            pkgs.steamPackages.steam-runtime
          ];
          nativeBuildInputs = [
            pkgs.pkgsi686Linux.autoPatchelfHook
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
            addAutoPatchelfSearchPath ${pkgs.steamPackages.steam-runtime}/usr/lib/i386-linux-gnu/
            addAutoPatchelfSearchPath ${pkgs.steamPackages.steam-runtime}/lib/i386-linux-gnu/
            addAutoPatchelfSearchPath $out/bin
          '';
          # AFAIK these aren't needed for the headless server
          autoPatchelfIgnoreMissingDeps = [
            "libtier0.so"
            "libvstdlib.so"
          ];
        };

        # Runnable server
        dedicated-server = pkgs.symlinkJoin {
          name = "garrys-mod-dedicated-server";
          paths = [
            steam-sdk-redist
            dedicated-server-content
            dedicated-server-linux-bins
          ];
        };

        # Wrapper for specifying options for Nix-supported usage
        run-wrapper = pkgs.writeShellScriptBin "run-gmod-server"
          (import ./run-wrapper.nix { inherit pkgs dedicated-server; });
      };

      default = garrys-mod.dedicated-server;
    };
  };
}