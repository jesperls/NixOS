{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.services.homeAssistant;
in
{
  options.mySystem.services.homeAssistant = {
    enable = lib.mkEnableOption "the Home Assistant desktop agent";

    privileged = lib.mkEnableOption "SMART and user-activity sensors, granting the agent root-equivalent capabilities";

    glances = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Serve the Glances API for Home Assistant's Glances integration.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 61208;
        description = "Port the Glances web server listens on.";
      };
    };

    mqtt = {
      enable = lib.mkEnableOption "MQTT, which the agent needs for controls and notifications";

      server = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "tcp://nuwa:1883";
        description = "URI of the MQTT broker.";
      };

      user = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "MQTT username, or null for anonymous access.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/etc/go-hass-agent-mqtt-password";
        description = "File holding the MQTT password, read at service start.";
      };

      topicPrefix = lib.mkOption {
        type = lib.types.str;
        default = "homeassistant";
        description = "MQTT topic prefix the agent publishes under.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.mqtt.enable -> cfg.mqtt.server != "";
        message = "mySystem.services.homeAssistant.mqtt.server must be set when mqtt is enabled.";
      }
    ];

    services.glances = lib.mkIf cfg.glances.enable {
      enable = true;
      port = cfg.glances.port;
      openFirewall = true;
    };

    security.wrappers.go-hass-agent = lib.mkIf cfg.privileged {
      source = lib.getExe pkgs.go-hass-agent;
      owner = "root";
      group = "users";
      permissions = "u+rx,g+x,o-x";
      capabilities = "cap_setuid,cap_setgid,cap_sys_rawio,cap_sys_admin,cap_mknod,cap_dac_override+ep";
    };
  };
}
