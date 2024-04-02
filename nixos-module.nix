{
  pkgs,
  lib,
  stdenvNoCC,
  config,
  ...
}:
with lib;
let
  gpkgs = pkgs.callPackage ./default.nix {};
  cfg = config.services.garrys-mod;
  defaultUser = {
    name = "garrys-mod";
    group = "garrys-mod";
    isSystemUser = true;
    createHome = true;
    home = cfg.dataDir;
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
      example = "gms_g4p_stargate_v11";
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
      example = [
        (stdenvNoCC.mkDerivation {
          pname = "gmstranded";
          version = "19.00.00";

          src = fetchFromGitHub {
            owner = "TGRCDev";
            repo = "GMStranded";
            rev = "b586f62047c9dabcff8317c8fc9b34e5b78caf5c";
            hash = "sha256-eVzdKaTyM3pgAPNEqYkdAtdqN/QnTXNQYJ98HHCxyxw=";
          };

          buildPhase = ''
            mkdir $out
            cp -r $src/gamemodes $src/maps $src/particles $src/data $out/
          '';
        })
      ];
      type = with types; listOf package;
      description = ''
        A list of derivations whose contents are linked to the fake srcds dir when the
        server is started. Use this to add additional files (maps, gamemodes, scripts, etc.)
        to the server without needing a workshop collection.
      '';
    };
    extraArgs = mkOption {
      example = "+sv_lan 1";
      default = "";
      type = with types; str;
      description = ''
        Additional arguments to pass to `srcds_run`.
      '';
    };
    user = mkOption {
      default = "garrys-mod";
      type = with types; str;
      description = ''
        The user account to run the server with.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.garrys-mod = let
      serverPkg = gpkgs.dedicated-server-unwrapped.override { inherit (cfg) extraPaths; };
      runWrapper = gpkgs.dedicated-server.override { dedicated-server-unwrapped = serverPkg; };
    in {
      description = "Garry's Mod dedicated server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        ExecStart = pkgs.writeShellScript "gmod-exec-start" ''
          ${runWrapper}/bin/run-gmod-server --data-dir "${cfg.dataDir}" -- \
          -port ${builtins.toString cfg.port} \
          ${ if cfg.address != null then "-ip ${cfg.address} " else "" } \
          +gamemode ${cfg.gamemode} \
          +map ${cfg.map} \
          ${ if cfg.workshopCollection != null then "+host_workshop_collection ${builtins.toString cfg.workshopCollection}" else ""} \
          ${cfg.extraArgs}
        '';
      };
    };
    users = mkIf (cfg.user == defaultUser.name) {
      users.garrys-mod = defaultUser;
      groups.garrys-mod = {};
    };
  };
}