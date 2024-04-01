# Frequently Asked Questions

## How do I set the hostname / password / GLST token / etc.

There are two options, depending on if the setting is a sensitive secret:
1. Pass it through `services.garrys-mod.extraArgs`.

This will ensure that the setting persists even if you reset the data directory. However, this will also expose the setting to the globally visible nix variable, so it should not be used for secrets.
```nix
# configuration.nix
{
    services.garrys-mod.extraArgs = "+hostname 'My Epic Server'";
}
```

2. Set the console variable through the server's `autoexec.cfg` or `server.cfg`.

This will be lost if the data directory is reset, but it is not globally visible, so it is the preferred method of passing your GLST token or setting your server's password.
```bash
# cfg/autoexec.cfg
hostname "My Epic Server"
sv_password "myfunnypassword"
sv_setsteamaccount "GlstTokenGoesHere"
```

The default permissions for `autoexec.cfg` are group readable and writable. If you want to pass certain options more securely, you can make an additional file under `cfg` with more restrictive permissions and call it from `autoexec.cfg` like so:
```bash
# cfg/autoexec.cfg (permissions 770)
hostname "My Epic Server"
sv_password "myfunnypassword"
exec glst.cfg
```
```bash
# cfg/glst.cfg (permissions 500)
sv_setsteamaccount "GlstTokenGoesHere"
```

## What happens if a file exists in both the data directory and the store files?

During server startup, we create a fake writeable server folder in `/tmp` and symbolically link all the files and directories we need. These files are linked in this order, with the earliest entries getting the highest priority:
```
Data Directory -> extraPaths Derivations -> Store Derivation
```

Thus, any file (not directories) that exists in the data directory will mask the same file within the Nix store's `garrysmod` directory.