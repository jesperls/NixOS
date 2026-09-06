{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.mySystem.services.homeAssistant;

  agent = if cfg.privileged then "/run/wrappers/bin/go-hass-agent" else lib.getExe pkgs.go-hass-agent;

  configureMqtt = pkgs.writeShellApplication {
    name = "go-hass-agent-configure";
    runtimeInputs = [
      pkgs.go-hass-agent
      pkgs.coreutils
    ];
    text =
      if !cfg.mqtt.enable then
        ''
          go-hass-agent --no-log-file config --no-mqtt-enabled
        ''
      else
        ''
          ${lib.optionalString (
            cfg.mqtt.passwordFile != null
          ) "password=$(cat -- ${lib.escapeShellArg cfg.mqtt.passwordFile})"}
          go-hass-agent --no-log-file config \
            --mqtt-enabled \
            --mqtt-server ${lib.escapeShellArg cfg.mqtt.server} \
            --mqtt-topic-prefix ${lib.escapeShellArg cfg.mqtt.topicPrefix} \
            ${lib.optionalString (cfg.mqtt.user != null) "--mqtt-user ${lib.escapeShellArg cfg.mqtt.user}"} \
            ${lib.optionalString (cfg.mqtt.passwordFile != null) ''--mqtt-password "$password"''}
        '';
  };
in
lib.mkIf cfg.enable {
  home.packages = [
    pkgs.go-hass-agent
    pkgs.ffmpeg
  ];

  systemd.user.services.go-hass-agent = import ../lib/autostart.nix {
    description = "Go Hass Agent — Home Assistant desktop agent";
    execStart = "${agent} --no-log-file run";
    unit.StartLimitIntervalSec = 60;
    unit.StartLimitBurst = 5;
    service = {
      Restart = "always";
      RestartSec = 10;
      ExecStartPre = lib.getExe configureMqtt;
    };
  };
}
