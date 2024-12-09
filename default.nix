{
  pkgs ? import <nixpkgs> {},
}: let
  callPackage = pkgs.lib.callPackageWith (pkgs // packages);
  packages = rec {
    # Fetcher for Steam game depots
    fetchDepot = callPackage ./packages/depots/fetch-depot.nix {};

    # Fetcher for Steam runtimes
    fetchRuntime = callPackage ./packages/depots/fetch-runtime.nix {};

    # Steam runtime shared libraries
    steam-runtime = callPackage ./packages/depots/steam-runtime.nix {};

    # steamclient.so
    steam-sdk-redist = callPackage ./packages/depots/steam-sdk-redist.nix {};

    # Game content
    server-content = callPackage ./packages/depots/server-content.nix {};

    # Dedicated server binaries and scripts for Linux, including srcds_run and srcds_linux
    server-binaries-unpatched = callPackage ./packages/depots/server-binaries-unpatched.nix {};

    # Patched server binaries and scripts to work in Nix
    server-binaries = callPackage ./packages/depots/server-binaries.nix {};

    # Unpatched, runnable server. Requires steam-run to use
    dedicated-server-unpatched-unwrapped = callPackage ./packages/dedicated-server-unpatched-unwrapped.nix {};

    # Patched, runnable server
    dedicated-server-unwrapped = callPackage ./packages/dedicated-server-unwrapped.nix {};

    # Wrapper that uses bwrap and supports declaring a separate data directory
    dedicated-server = callPackage ./packages/dedicated-server.nix {};

    default = dedicated-server;
  };
in packages