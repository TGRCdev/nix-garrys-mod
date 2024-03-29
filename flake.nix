{
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    fetchDepot = pkgs.callPackage ./packages/depots/fetch-depot.nix {};
    stdenv = pkgs.stdenvNoCC;
  in {
    packages.${system} = rec {
      inherit fetchDepot;
      steam-sdk-redist = pkgs.callPackage ./packages/depots/steam-sdk-redist.nix { inherit fetchDepot; };
      garrys-mod = rec {
        # Actual game content, does not need fixup
        server-content = pkgs.callPackage ./packages/depots/server-content.nix { inherit fetchDepot; };

        # Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
        server-binaries = pkgs.callPackage ./packages/depots/server-binaries.nix { inherit fetchDepot; };

        # Runnable server
        dedicated-server = pkgs.symlinkJoin {
          name = "garrys-mod-dedicated-server";
          paths = [
            steam-sdk-redist
            server-content
            server-binaries
          ];
        };

        # Wrapper for faking a write-able dedicated server folder in /tmp
        run-wrapper = pkgs.writeShellScriptBin "run-gmod-server"
          (import ./packages/run-wrapper.nix { inherit pkgs dedicated-server; });
      };

      default = garrys-mod.run-wrapper;
    };
  };
}