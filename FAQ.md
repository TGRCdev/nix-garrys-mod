# Frequently Asked Questions

## Can I add custom files to the server derivation?

Yes! For the NixOS module, you can include additional derivations in `services.garrys-mod.extraPaths`, and they will be merged with the base server derivation. Here is an example of what I use to run [my gamemode](https://github.com/TGRCDev/GMStranded.git).
```nix
{
  services.garrys-mod = let
    gmstranded-src = pkgs.fetchFromGitHub {
      owner = "TGRCDev";
      repo = "GMStranded";
      rev = "4bc8f7cf88be1c6965282167f6151e754651777d";
      hash = "sha256-6eRWMU75SpgZgYu6bzOSDP0cs879dPgNR8pWqpcGr4A=";
    };
    # Modify the derivation to correctly link into the srcds directory
    gmstranded = pkgs.runCommandLocal "gmstranded" { src = gmstranded-src; } ''
      mkdir -p $out/garrysmod
      cp -Rs $src/data $src/gamemodes $src/particles $out/garrysmod
    '';
  in {
    enable = true;
    gamemode = "gmstranded";
    map = "gms_g4p_stargate_v11";
    workshopCollection = 3035416339;
    extraPaths = [ gmstranded ];
  };
}
```

**IMPORTANT NOTE**: I use `cp -Rs` to recursively link files instead of using `ln -s` on the directories. This is required so that file clobbering works. If you simply symlink the directories it will **NOT** work.

For the `dedicated-server-unwrapped`/`dedicated-server-unwrapped-unpatched` packages, you can override `extraPaths`.

```nix
dedicated-server-unwrapped.override ({
    extraPaths = [ ... ];
})
```

For the `dedicated-server` run wrapper, override `dedicated-server-unwrapped`.
```nix
dedicated-server.override ({
    dedicated-server-unwrapped = dedicated-server-unwrapped.override ({
        extraPaths = [ ... ];
    });
})
```

## What happens if a file exists in both the data directory and the store files?

During server startup, we create a fake writeable server folder in `/tmp` and symbolically link all the files and directories we need. We link from directories in this order, overlaying any files that collide with the previous step:
```
  Base Server Derivation
         |
         v
  extraPaths Derivations
         |
         v
--extra-paths Directories
         |
         v
    Data Directory
```

Thus, any file that exists in the data directory will mask the same file within the Nix store's `garrysmod` directory.

NOTE: `garrysmod/data`, `garrysmod/cache` and `steam_cache` are special cases. They are symlinked directly to the data directory's respective directories after the fake directory has been fully clobbered.