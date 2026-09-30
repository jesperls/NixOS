{
  pkgs,
  lib,
  host,
}:
let
  apply = import ../modules/home-manager/lib/apply-shell-settings.nix {
    inherit pkgs lib;
    configDir = "config with 'quotes' and $dollars";
    dataDir = "data";
    settings = {
      system = {
        idle.lock.timeout = 42;
        list = [ "replacement" ];
      };
      pinnedapps.apps = [ "kitty" ];
    };
  };

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
      modules = [
        { mySystem.desktop.shell.settings = lib.mkForce { }; }
      ];
    }).config;
  invalidShellConfig =
    (host.extendModules {
      modules = [ { mySystem.desktop.shell.settings.unknownFile.value = true; } ];
    }).config;

  valid = config: builtins.all (entry: entry.assertion) config.assertions;
  user = host.config.mySystem.user.username;
  emptyService = emptyShellConfig.home-manager.users.${user}.systemd.user.services.pangu.Service;
  overrideFile =
    config:
    lib.removePrefix "PANGU_NIX_OVERRIDES=" (
      lib.findFirst (entry: lib.hasPrefix "PANGU_NIX_OVERRIDES=" entry)
        (throw "Pangu override metadata is missing")
        config.home-manager.users.${user}.systemd.user.services.pangu.Service.Environment
    );
in
assert valid shellConfig;
assert !(valid invalidShellConfig);
assert emptyService.ExecStartPre == [ ];
assert !(builtins.any (entry: lib.hasPrefix "PANGU_NIX_OVERRIDES=" entry) emptyService.Environment);
pkgs.runCommand "shell-settings-check" { nativeBuildInputs = [ pkgs.python3 ]; } ''
  python3 ${./test_shell_settings.py} ${lib.getExe apply}
  python3 - ${lib.escapeShellArg (overrideFile shellConfig)} <<'PY'
  import json
  import sys
  with open(sys.argv[1]) as stream:
      assert json.load(stream) == ["pinnedapps.apps", "system.ocr.eng"]
  PY
  touch "$out"
''
