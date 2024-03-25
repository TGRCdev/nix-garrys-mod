{
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

      steam-service = stdenv.mkDerivation {
        src = steam-sdk-redist;

        name = "steam-service";
        phases = [ "fixupPhase" ];
        fixupPhase = ''
          mkdir -p $out/linux64
          ln -s $src/steamclient.so $out/steamservice.so
          ln -s $src/linux64/steamclient.so $out/linux64/steamservice.so
        '';
      };

      garrys-mod = rec {
        dedicated-server-content = fetchDepot {
          name = "dedicated-server-content";
          appId = 4020;
          depotId = 4021;
          manifestId = 5179858603377479094;
          outputHash = "sha256-viuPi6ou5EJRqkFW9jpFm8KZNz9ROjivWx1XBQjRJZc=";
        };
        dedicated-server-linux-src = fetchDepot {
          name = "dedicated-server-linux-src";
          appId = 4020;
          depotId = 4023;
          manifestId = 1978825540093010308;
          outputHash = "sha256-QWqoAo+niwhu1Ksju/57bRWfMGaAWhphzMUQRoLzmls=";
        };
        runWrapper = let
          steam-run = (pkgs.steam-run);
        in pkgs.stdenvNoCC.mkDerivation {
          name = "garrys-mod-server-wrapper";
          src = pkgs.symlinkJoin {
            name = "garrys-mod-server";
            paths = [
              steam-sdk-redist
              steam-service
              dedicated-server-content
              dedicated-server-linux-src
            ];
          };
          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = [ steam-run ];
          buildPhase = ''
            mkdir -p $out/bin
            echo "#!${pkgs.bash}/bin/bash
            ${steam-run}/bin/steam-run $src/srcds_run \"\$@\"
            " >> $out/bin/run-gmod-server
            chmod +x $out/bin/run-gmod-server
          '';
          meta.mainProgram = "run-gmod-server";
        };
      };

      default = garrys-mod.runWrapper;
    };

    devShells.${system}.default = pkgs.buildFHSUserEnv {
      name = "steamcmd-fhs";
      multiArch = true;
      multiPkgs = pkgs: with pkgs; [ steamcmd ];
    };
  };
}