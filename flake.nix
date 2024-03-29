{
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    pkgsi686Linux = pkgs.pkgsi686Linux;
    fetchDepot = (pkgs.callPackage ./depot.nix {}).fetchDepot;
    stdenv = pkgs.stdenvNoCC;
  in {
    packages.${system} = rec {
      steam-sdk-redist = fetchDepot {
        name = "steam-sdk-redist";
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
        dedicated-server-linux-src = fetchDepot {
          name = "garrys-mod-dedicated-server-linux-src";
          appId = 4020;
          depotId = 4023;
          manifestId = 1978825540093010308;
          outputHash = "sha256-QWqoAo+niwhu1Ksju/57bRWfMGaAWhphzMUQRoLzmls=";
        };
        dedicated-server = stdenv.mkDerivation {
          name = "garrys-mod-dedicated-server";
          srcs = [
            steam-sdk-redist
            dedicated-server-content
            dedicated-server-linux-src
          ];
          unpackPhase = "true";

          buildPhase = ''
            mkdir $out
            # Link dedicated server content
            ln -s ${dedicated-server-content}/* $out
            rm $out/bin
            mkdir $out/bin
            ln -s ${dedicated-server-content}/bin/* $out/bin
            rm $out/garrysmod
            mkdir $out/garrysmod
            ln -s ${dedicated-server-content}/garrysmod/* $out/garrysmod

            # Copy steam redist
            cp -r ${steam-sdk-redist}/* $out/
            
            # Copy dedicated server linux binaries
            cp -r ${dedicated-server-linux-src}/* $out/
            
            echo "4000" > $out/steam_appid.txt
          '';
        };
      };

      default = garrys-mod.dedicated-server;
    };
  };
}