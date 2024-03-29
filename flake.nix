{
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    pkgsi686Linux = pkgs.pkgsi686Linux;
    fetchDepot = (pkgs.callPackage ./depot.nix {}).fetchDepot;
    fetchRuntime = (pkgs.callPackage ./runtime.nix {}).fetchRuntime;
    stdenv = pkgs.stdenvNoCC;
  in {
    packages.${system} = rec {
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
        dedicated-server-content = fetchDepot {
          name = "dedicated-server-content";
          appId = 4020;
          depotId = 4021;
          manifestId = 5179858603377479094;
          outputHash = "sha256-rUiQ+xwaw+meBTVFwBFY8ZjOCOOvvdI0vjX9p2ZgsSs=";
        };
        dedicated-server-linux = let 
          runtime = pkgs.steamPackages.steam-runtime;
        in stdenv.mkDerivation {
          name = "garrys-mod-dedicated-server-linux";
          src = fetchDepot {
            name = "garrys-mod-dedicated-server-linux-src";
            appId = 4020;
            depotId = 4023;
            manifestId = 1978825540093010308;
            outputHash = "sha256-QWqoAo+niwhu1Ksju/57bRWfMGaAWhphzMUQRoLzmls=";
          };
          buildInputs = [ runtime ];
          nativeBuildInputs = [
            pkgsi686Linux.autoPatchelfHook
          ];
          autoPatchelfIgnoreMissingDeps = [
            "libtier0.so"
            "libvstdlib.so"
          ];
          buildPhase = ''
            addAutoPatchelfSearchPath ${runtime}/usr/lib/i386-linux-gnu/
            addAutoPatchelfSearchPath ${runtime}/lib/i386-linux-gnu/
            
            mkdir $out
            cp -r $src/* $out

            chmod -R +w $out

            addAutoPatchelfSearchPath $out/bin
          '';
        };
        dedicated-server = pkgs.symlinkJoin {
          name = "garrys-mod-dedicated-server";
          paths = [
            steam-sdk-redist
            dedicated-server-content
            dedicated-server-linux
          ];
          meta.mainProgram = "../srcds_run";
        };
      };

      default = garrys-mod.dedicated-server;
    };
  };
}