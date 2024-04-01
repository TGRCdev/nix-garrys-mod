# Frequently Asked Questions

## Can I add custom files to the server derivation?

Yes! For the NixOS module, you can include additional derivations in `services.garrys-mod.extraPaths`, and they will be merged with the `dedicated-server` derivation using `pkgs.buildEnv`. Here is an example of what I use to run [my gamemode](https://github.com/TGRCDev/GMStranded.git).
```nix
services.garrys-mod = {
  enable = true;
  gamemode = "gmstranded";
  map = "gms_g4p_stargate_v11";
  workshopCollection = 3035416339;
  extraPaths = let
    gmstranded = pkgs.fetchFromGitHub {
        owner = "TGRCDev";
        repo = "GMStranded";
        rev = "4bc8f7cf88be1c6965282167f6151e754651777d";
        hash = "sha256-6eRWMU75SpgZgYu6bzOSDP0cs879dPgNR8pWqpcGr4A=";
    };
  in [ # It's a little out of order, so I have to symlink a bit
    (pkgs.runCommandLocal "gmstranded" { inherit gmstranded; } ''
      mkdir -p $out/garrysmod
      ln -s $gmstranded/data $gmstranded/gamemodes $gmstranded/particles $out/garrysmod
    '')
  ];
};
```

For the plain `dedicated-server`/`dedicated-server-unpatched` packages, you can override them and pass `extraPaths`.

```nix
dedicated-server.override ({
    extraPaths = [ ... ];
})
```

For the `run-wrapper`, override `dedicated-server`.
```nix
run-wrapper.override ({
    dedicated-server = dedicated-server.override ({
        extraPaths = [ ... ];
    });
})
```

## What happens if a file exists in both the data directory and the store files?

During server startup, we create a fake writeable server folder in `/tmp` and symbolically link all the files and directories we need. We link from directories in this order, overlaying any files that collide with the previous step:
```
  Base Server Derivation (+extraPaths derivs)
         |
         v
--extra-paths Directories
         |
         v
    Data Directory
```

Thus, any file that exists in the data directory will mask the same file within the Nix store's `garrysmod` directory.