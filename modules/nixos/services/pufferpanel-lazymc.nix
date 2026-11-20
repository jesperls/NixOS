{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.services.pufferpanelLazymc;
  bridge = pkgs.callPackage ../../../pkgs/pufferpanel-lazymc-bridge.nix { };
  gate = pkgs.callPackage ../../../pkgs/mc-host-gate.nix { };
  useGate = cfg.allowedHostnames != [ ];
  serverPort = lib.last (lib.splitString ":" cfg.serverAddress);
  wakeServerProperties = pkgs.writeText "lazymc-server.properties" ''
    enable-rcon=false
    enable-status=true
    server-ip=
    server-port=${serverPort}
    white-list=true
  '';
  tomlFormat = pkgs.formats.toml { };

  lazymcConfig = tomlFormat.generate "lazymc.toml" {
    public = {
      address = if useGate then cfg.gateAddress else cfg.publicAddress;
      version = cfg.mcVersion;
      inherit (cfg) protocol;
    };

    server = {
      address = cfg.serverAddress;
      directory = cfg.serverDirectory;
      command = lib.getExe bridge;
      freeze_process = false; # Must be false on Linux or lazymc sends SIGSTOP to the bridge instead of SIGTERM.
      wake_on_start = false;
      wake_on_crash = false;
      probe_on_start = false; # Avoids waking the server on host boot.
      forge = false; # NeoForge 1.21 uses vanilla login/config packets, not FML2.
      start_timeout = cfg.startTimeout;
      stop_timeout = cfg.stopTimeout;
      wake_whitelist = true;
      block_banned_ips = true;
    };

    time = {
      sleep_after = cfg.sleepAfter;
      minimum_online_time = cfg.minimumOnlineTime;
    };

    motd = {
      inherit (cfg.motd) sleeping starting stopping;
      from_server = cfg.motd.fromServer;
    };

    join = {
      methods = lib.optional (cfg.holdTimeout > 0) "hold" ++ [ "kick" ];
      kick = {
        inherit (cfg.kickMessage) starting stopping;
      };
    }
    // lib.optionalAttrs (cfg.holdTimeout > 0) {
      hold.timeout = cfg.holdTimeout;
    };

    rcon.enabled = false;
    advanced.rewrite_server_properties = false;
    config.version = pkgs.lazymc.version;
  };
in
{
  options.mySystem.services.pufferpanelLazymc = {
    serverId = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "PufferPanel server identifier managed by lazymc.";
    };

    serverDirectory = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Host path to the Minecraft server directory for whitelist and ban checks.";
    };

    pufferpanelUrl = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "http://127.0.0.1:8080";
      description = "Base URL of the local PufferPanel instance.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "/etc/lazymc/pufferpanel.env";
      description = "Root-readable env file providing PUFFERPANEL_CLIENT_ID and PUFFERPANEL_CLIENT_SECRET.";
    };

    publicAddress = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "0.0.0.0:25565";
      description = "Public address and port players connect to.";
    };

    gateAddress = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "127.0.0.1:25567";
      description = "Internal address lazymc listens on when allowedHostnames filtering is active.";
    };

    allowedHostnames = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [ ];
      description = "Minecraft handshake hostnames allowed to reach lazymc; empty disables hostname filtering.";
    };

    wakeOnlyWhitelist = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enforce whitelist.json in lazymc for waking even when Minecraft has white-list=false.";
    };

    serverAddress = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "127.0.0.1:25566";
      description = "Internal address and port the Minecraft server listens on.";
    };

    mcVersion = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "1.21.1";
      description = "Minecraft version string advertised while sleeping.";
    };

    protocol = lib.mkOption {
      type = lib.types.ints.positive;
      default = 767;
      description = "Minecraft protocol number advertised while sleeping.";
    };

    sleepAfter = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1800;
      description = "Seconds with zero players before stopping the server into standby.";
    };

    minimumOnlineTime = lib.mkOption {
      type = lib.types.ints.positive;
      default = 120;
      description = "Minimum seconds the server stays running after waking.";
    };

    startTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 300;
      description = "Maximum seconds allowed for the server to finish starting.";
    };

    stopTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 150;
      description = "Maximum seconds allowed for a graceful server shutdown.";
    };

    holdTimeout = lib.mkOption {
      type = lib.types.ints.between 0 29;
      default = 15;
      description = "Seconds to hold a joining client before kicking with the starting message; zero kicks immediately.";
    };

    motd = {
      sleeping = lib.mkOption {
        type = lib.types.str;
        default = "Server is sleeping\nJoin to start it up";
        description = "Server list MOTD shown while in standby.";
      };

      starting = lib.mkOption {
        type = lib.types.str;
        default = "Server is starting...\nPlease wait...";
        description = "Server list MOTD shown while booting.";
      };

      stopping = lib.mkOption {
        type = lib.types.str;
        default = "Server going to sleep...\nPlease wait...";
        description = "Server list MOTD shown while shutting down.";
      };

      fromServer = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use the real server MOTD once awake.";
      };
    };

    kickMessage = {
      starting = lib.mkOption {
        type = lib.types.str;
        default = "Server is waking up... Please reconnect in a minute.";
        description = "Disconnect message shown when waking the server from standby.";
      };

      stopping = lib.mkOption {
        type = lib.types.str;
        default = "Server is entering standby. Reconnect in a moment to wake it.";
        description = "Disconnect message shown if joining while the server is stopping.";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.publicAddress != cfg.serverAddress;
        message = "mySystem.services.pufferpanelLazymc.publicAddress and serverAddress must differ.";
      }
    ];

    environment.etc."lazymc/lazymc.toml".source = lazymcConfig;

    systemd.services.lazymc = {
      description = "Minecraft on-demand wake/standby proxy (lazymc + PufferPanel)";
      after = [
        "network-online.target"
        "docker.service"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig.ConditionPathExists = cfg.environmentFile;

      environment = {
        PUFFERPANEL_URL = cfg.pufferpanelUrl;
        PUFFERPANEL_SERVER_ID = cfg.serverId;
        PUFFERPANEL_STOP_TIMEOUT = toString (lib.max 30 (cfg.stopTimeout - 15));
      };

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${lib.getExe pkgs.lazymc} --config ${lazymcConfig} start";
        Restart = "on-failure";
        RestartSec = "5s";
        TimeoutStopSec = cfg.stopTimeout + 15;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
      }
      // lib.optionalAttrs cfg.wakeOnlyWhitelist {
        BindReadOnlyPaths = [
          "${wakeServerProperties}:${cfg.serverDirectory}/server.properties" # Show white-list=true to lazymc without enabling Minecraft's whitelist.
        ];
      };
    };

    systemd.services.mc-host-gate = lib.mkIf useGate {
      description = "Minecraft handshake hostname gate in front of lazymc";
      after = [
        "network-online.target"
        "lazymc.service"
      ];
      wants = [ "network-online.target" ];
      requires = [ "lazymc.service" ];
      partOf = [ "lazymc.service" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig.ConditionPathExists = cfg.environmentFile;

      environment = {
        MC_GATE_LISTEN = cfg.publicAddress;
        MC_GATE_UPSTREAM = cfg.gateAddress;
        MC_GATE_ALLOWED_HOSTS = lib.concatStringsSep "," cfg.allowedHostnames;
      };

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = lib.getExe gate;
        Restart = "on-failure";
        RestartSec = "2s";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
      };
    };
  };
}
