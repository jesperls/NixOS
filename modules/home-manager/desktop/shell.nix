{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.mySystem.desktop.shell;

  settings = cfg.settings;

  mkPatch = name: value: ''
    file="$conf/${name}.json"
    overrides=${lib.escapeShellArg (builtins.toJSON value)}
    if [ -s "$file" ]; then
      jq --argjson overrides "$overrides" '. * $overrides' "$file" >"$file.tmp"
      mv "$file.tmp" "$file"
    else
      printf '%s\n' "$overrides" >"$file"
    fi
  '';

  applySettings = pkgs.writeShellApplication {
    name = "pangu-apply-settings";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      conf="${config.xdg.configHome}/pangu/config"
      mkdir -p "$conf" "${config.xdg.dataHome}/pangu"

      ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkPatch settings)}
    '';
  };
in
lib.mkIf cfg.enable {
  home.packages = [ pkgs.pangu ];

  systemd.user.services.pangu = import ../lib/autostart.nix {
    description = "Pangu — desktop shell";
    execStart = lib.getExe pkgs.pangu;
    unit.ConditionEnvironment = "WAYLAND_DISPLAY";
    service = {
      ExecStartPre = lib.getExe applySettings;
      RuntimeDirectory = "pangu";
      Slice = "session.slice";
      Environment = [ "PANGU_WALLPAPERS=${cfg.wallpapers}" ];
    };
  };
}
