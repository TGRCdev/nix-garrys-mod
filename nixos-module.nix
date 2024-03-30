run-wrapper: { lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.garrys-mod;
  defaultUser = {
    name = "garrys-mod";
    group = "garrys-mod";
    isSystemUser = true;
    home = "/var/lib/garrys-mod";
    createHome = true;
    packages = [ run-wrapper ];
  };
in {
  imports = [];
  options.services.garrys-mod = {
    enable = mkEnableOption "Garry's Mod";
    dataDir = mkOption {
      example = "/var/lib/gmstranded/";
      default = "/var/lib/garrys-mod/";
      type = types.str;
      description = ''
        The directory containing the stateful data of the Garry's Mod server.
        In a typical steamcmd installation, this would be the `garrysmod` folder.
      '';
    };
    address = mkOption {
      example = "127.0.0.1";
      default = null;
      type = with types; nullOr str;
      description = ''
        The address to bind the Garry's Mod server to.
        (NOTE: srcds_run seems to ignore this completely. Check `netstat` when running.)
      '';
    };
    port = mkOption {
      example = 27805;
      default = 27015;
      type = types.port;
      description = ''
        The port to bind the Garry's Mod server to.
      '';
    };
    gamemode = mkOption {
      example = "terrortown";
      default = "sandbox";
      type = types.str;
      description = ''
        The gamemode to run on the server.
        Make sure it's present in `{dataDir}/gamemodes` or downloaded by `workshopCollection`.
      '';
    };
    map = mkOption {
      example = "gm_flatgrass";
      default = "gm_construct";
      type = types.str;
      description = ''
        The map to run on the server.
        Make sure it's present in `{dataDir}/maps` or downloaded by `workshopCollection`.
      '';
    };
    workshopCollection = mkOption {
      example = 3035416339;
      default = null;
      type = with types; nullOr int;
      description = ''
        A workshop collection that srcds_run will download before starting the server.
      '';
    };
    extraPaths = mkOption {
      default = [];
      type = with types; listOf package;
      description = ''
        A list of derivations whose contents are linked to the fake srcds dir when the
        server is started. Use this to add additional files (maps, gamemodes, scripts etc.)
        to the server without needing a workshop collection.
      '';
    };
    extraArgs = mkOption {
      example = "+sv_lan 1";
      default = null;
      type = with types; nullOr str;
      description = ''
        Additional arguments to pass to `srcds_run`.
      '';
    };
    user = mkOption {
      default = "garrys-mod";
      type = with types; nullOr str;
      description = ''
        The user account to run the server with.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.garrys-mod = builtins.trace cfg {
      description = "Garry's Mod dedicated server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        ExecStart = pkgs.writeShellScript "gmod-exec-start" ''
          ${run-wrapper}/bin/run-gmod-server --data-dir "${cfg.dataDir}" --extra-paths "${lib.strings.concatStringsSep " " cfg.extraPaths}" -- \
          -port ${builtins.toString cfg.port} \
          ${ if cfg.address != null then "-ip ${cfg.address} " else "" } \
          +gamemode ${cfg.gamemode} \
          +map ${builtins.trace cfg.map cfg.map} \
          ${ if cfg.workshopCollection != null then "+host_workshop_collection ${builtins.toString cfg.workshopCollection}" else ""} \
          ${ if cfg.extraArgs != null then cfg.extraArgs else "" }
        '';
      };
    };
    users = mkIf (cfg.user == defaultUser.name) {
      users.garrys-mod = defaultUser;
      groups.garrys-mod = {};
    };
  };
}