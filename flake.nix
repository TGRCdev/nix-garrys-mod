{
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    pkgsi686Linux = pkgs.pkgsi686Linux;
    fetchDepot = (pkgs.callPackage ./depot.nix {}).fetchDepot;
    fetchRuntime = (pkgs.callPackage ./runtime.nix {}).fetchRuntime;
  in {
    packages.${system} = rec {
      steam-sdk-redist = fetchDepot {
        name = "steam-sdk-redist";
        appId = 4020;
        depotId = 1006;
        manifestId = 4884950798805348056;
        phases = [ "buildPhase" "fixupPhase" ];
        fixupPhase = ''
          chmod +x $out/steamclient.so
          chmod +x $out/linux64/steamclient.so
        '';
        outputHash = "sha256-iivdtcBaMQIyWkA7O1xtBpP41R+4WrsDS8ISIfr8Os8=";
      };
      garrys-mod = rec {
        dedicated-server-content = fetchDepot {
          name = "dedicated-server-content";
          appId = 4020;
          depotId = 4021;
          manifestId = 7918776424147734184;
          outputHash = "sha256-viuPi6ou5EJRqkFW9jpFm8KZNz9ROjivWx1XBQjRJZc=";
        };
        dedicated-server-linux-src = fetchDepot {
          name = "dedicated-server-linux-src";
          appId = 4020;
          depotId = 4023;
          manifestId = 3728493952843195777;
          outputHash = "sha256-cwyJzU5+xA8bcsuOBXNbR/bNXAQNVXxEfv6DLviHq6I=";
        };
        runWrapper = let
          steam-run = (pkgs.steam-run);
        in pkgs.stdenvNoCC.mkDerivation {
          name = "garrys-mod-server-wrapper";
          src = pkgs.symlinkJoin {
            name = "garrys-mod-server";
            paths = [
              steam-sdk-redist
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
        };
      };
    };
  };
}