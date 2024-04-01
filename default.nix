{
  pkgs ? import <nixpkgs> {},
}: let
  callPackage = pkgs.lib.callPackageWith (pkgs // packages);
  flake = builtins.getFlake ./flake.nix;
  packages = {
    # Fetcher for Steam game depots
    fetchDepot = callPackage ./packages/depots/fetch-depot.nix {};

    # steamclient.so
    steam-sdk-redist = callPackage ./packages/depots/steam-sdk-redist.nix {};

    # Actual game content, does not need fixup
    server-content = callPackage ./packages/depots/server-content.nix {};

    # Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
    server-binaries-unpatched = callPackage ./packages/depots/server-binaries-unpatched.nix {};

    # Patched server binaries and scripts to work in Nix
    server-binaries = callPackage ./packages/depots/server-binaries.nix {};

    # Patched, runnable server
    dedicated-server = callPackage ./packages/dedicated-server.nix {};

    # Unpatched, runnable server. Requires steam-run to use
    dedicated-server-unpatched = callPackage ./packages/dedicated-server-unpatched.nix {};

    # Wrapper for declaring a write-able data directory, among other features 
    run-wrapper = callPackage ./packages/run-wrapper.nix {};
  };
in packages