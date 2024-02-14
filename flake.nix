{
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    pkgsi686Linux = pkgs.pkgsi686Linux;
    fetchDepot = (pkgs.callPackage ./depots {}).fetchDepot;
  in {
    packages.${system}.garrys-mod = rec {
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
      dedicated-server-content = fetchDepot {
        name = "dedicated-server-content";
        appId = 4020;
        depotId = 4021;
        manifestId = 7918776424147734184;
        outputHash = "sha256-viuPi6ou5EJRqkFW9jpFm8KZNz9ROjivWx1XBQjRJZc=";
      };
      dedicated-server-linux-unpatched = fetchDepot {
        name = "dedicated-server-linux-unpatched";
        appId = 4020;
        depotId = 4023;
        manifestId = 3728493952843195777;
        outputHash = "sha256-cwyJzU5+xA8bcsuOBXNbR/bNXAQNVXxEfv6DLviHq6I=";
      };
      dedicated-server-linux = let
        runtimeLibs = with pkgs.pkgsi686Linux; [
          gcc-unwrapped.lib
          ncurses5
          gperftools
        ];
      in pkgsi686Linux.stdenv.mkDerivation {
        name = "dedicated-server-linux";
        src = dedicated-server-linux-unpatched;
        buildInputs = runtimeLibs;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        buildPhase = ''
          mkdir $out
          ln -s $src/* $out/
          rm $out/srcds_linux
          cp $src/srcds_linux $out/srcds_linux
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