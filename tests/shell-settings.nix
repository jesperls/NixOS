{ pkgs, lib }:
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
in
pkgs.runCommand "shell-settings-check" { nativeBuildInputs = [ pkgs.python3 ]; } ''
  python3 ${./test_shell_settings.py} ${lib.getExe apply}
  touch "$out"
''
