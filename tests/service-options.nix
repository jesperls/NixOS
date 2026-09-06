{
  lib,
  pkgs,
  host,
}:
let
  configure =
    glances:
    (host.extendModules {
      modules = [
        {
          mySystem.services.homeAssistant = {
            enable = true;
            inherit glances;
          };
        }
      ];
    }).config;
  localConfig = configure { bind = "::1"; };
  disabledConfig = configure {
    enable = false;
    bind = "0.0.0.0";
  };
  exposedConfig = configure { bind = "0.0.0.0"; };
  protectedConfig = configure {
    bind = "0.0.0.0";
    passwordFile = "/run/secrets/glances-test-password";
  };
  validGlances = config: builtins.all (entry: entry.assertion) config.assertions;
  shellConfig =
    (host.extendModules {
      modules = [
        {
          mySystem.desktop.shell.settings = lib.mkForce {
            system.ocr.eng = true;
            pinnedapps.apps = [ "kitty" ];
            theme = { };
          };
        }
      ];
    }).config;
  emptyShellConfig =
    (host.extendModules {
      modules = [ { mySystem.desktop.shell.settings = lib.mkForce { }; } ];
    }).config;
  invalidShellConfig =
    (host.extendModules {
      modules = [ { mySystem.desktop.shell.settings.unknownFile.value = true; } ];
    }).config;
  mqttConfig =
    (host.extendModules {
      modules = [
        {
          mySystem.services.homeAssistant = {
            enable = true;
            mqtt = {
              enable = true;
              server = "tcp://test-broker:1883";
            };
          };
        }
      ];
    }).config;
  missingPasswordConfig =
    (host.extendModules {
      modules = [
        {
          mySystem.services.homeAssistant = {
            enable = true;
            mqtt = {
              enable = true;
              server = "tcp://test-broker:1883";
              passwordFile = "/run/secrets/missing-mqtt-test-password";
            };
          };
        }
      ];
    }).config;
  mqttScript =
    config: config.home-manager.users.jesperls.systemd.user.services.go-hass-agent.Service.ExecStartPre;
  overrideFile =
    config:
    lib.removePrefix "PANGU_NIX_OVERRIDES=" (
      lib.findFirst (entry: lib.hasPrefix "PANGU_NIX_OVERRIDES=" entry)
        (throw "Pangu override metadata is missing")
        config.home-manager.users.jesperls.systemd.user.services.pangu.Service.Environment
    );
  args = protectedConfig.services.glances.extraArgs;
in
assert validGlances shellConfig;
assert !(validGlances invalidShellConfig);
assert validGlances localConfig;
assert !localConfig.services.glances.openFirewall;
assert validGlances disabledConfig;
assert !disabledConfig.services.glances.enable;
assert !(validGlances exposedConfig);
assert validGlances protectedConfig;
assert protectedConfig.services.glances.openFirewall;
assert
  protectedConfig.systemd.services.glances.serviceConfig.LoadCredential == [
    "glances.pwd:/run/secrets/glances-test-password"
  ];
assert !(lib.elem "/run/secrets/glances-test-password" args);
pkgs.runCommand "home-assistant-service-check"
  {
    nativeBuildInputs = [
      pkgs.python3
      pkgs.glances
    ];
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    python3 ${./test_glances_auth.py} ${lib.escapeShellArgs args}
    python3 ${./test_mqtt_config.py} ${lib.escapeShellArg (mqttScript mqttConfig)} ${lib.escapeShellArg (mqttScript localConfig)} ${lib.escapeShellArg (mqttScript missingPasswordConfig)}
    python3 - ${lib.escapeShellArg (overrideFile shellConfig)} ${lib.escapeShellArg (overrideFile emptyShellConfig)} <<'PY'
    import json
    import sys
    with open(sys.argv[1]) as stream:
        assert json.load(stream) == ["pinnedapps.apps", "system.ocr.eng"]
    with open(sys.argv[2]) as stream:
        assert json.load(stream) == []
    PY
    touch "$out"
  ''
