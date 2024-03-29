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
      steam-sdk-redist = fetchDepot {
        name = "steam-sdk-redist-src";
        appId = 4020;
        depotId = 1006;
        manifestId = 4884950798805348056;
        outputHash = "sha256-IUoZ0JkpisMY4Pzqg3Bi99MhU6IRbBenQJspzq0PRLE=";
      };

      garrys-mod = rec {
        dedicated-server-content = fetchDepot {
          name = "dedicated-server-content";
          appId = 4020;
          depotId = 4021;
          manifestId = 5179858603377479094;
          outputHash = "sha256-rUiQ+xwaw+meBTVFwBFY8ZjOCOOvvdI0vjX9p2ZgsSs=";
        };
        dedicated-server-linux = fetchDepot {
          name = "garrys-mod-dedicated-server-linux";
          appId = 4020;
          depotId = 4023;
          manifestId = 1978825540093010308;
          outputHash = "sha256-QWqoAo+niwhu1Ksju/57bRWfMGaAWhphzMUQRoLzmls=";
        };
        dedicated-server = pkgs.symlinkJoin {
          name = "garrys-mod-dedicated-server";
          paths = [
            steam-sdk-redist
            dedicated-server-content
            dedicated-server-linux
          ];
        };
        run-wrapper = let
          wrapperScript = pkgs.writeShellScriptBin "run-gmod-server" ''
            export LD_LIBRARY_PATH="${dedicated-server}:${dedicated-server}/bin"
            ${pkgs.steam-run}/bin/steam-run ${dedicated-server}/srcds_run "$@"
          '';
        in stdenv.mkDerivation {
          name = "garrys-mod-run-wrapper";
          buildInputs = with pkgs; [
            steam-run
          ];
          src = null;
          phases = [ "buildPhase" ];

          buildPhase = ''
            mkdir $out
            cp -r ${wrapperScript}/* $out
          '';
        };
      };

      default = garrys-mod.run-wrapper;
    };
  };
}