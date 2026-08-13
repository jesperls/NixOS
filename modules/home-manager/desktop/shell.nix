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

  # ConfigFile names are declared in share/shell/config/Config.qml; parse them
  # so the nix API can't drift from the QML schema.
  configQml = builtins.readFile ../../../../share/shell/config/Config.qml;
  validFiles = builtins.concatLists (
    builtins.filter builtins.isList (builtins.split "ConfigFile[^}]*name: \"([a-z]+)\"" configQml)
  );

  mergeJq = ''
    def deepmerge($base; $over):
      reduce ($over | to_entries[]) as $e ($base;
        .[$e.key] =
          if ($base[$e.key] | type) == "object" and ($e.value | type) == "object"
          then deepmerge($base[$e.key]; $e.value)
          else $e.value
          end);
    deepmerge(.; $overrides)
  '';

  mkPatch = name: value: ''
    file="$conf/${name}.json"
    overrides=${lib.escapeShellArg (builtins.toJSON value)}
    if [ -s "$file" ]; then
      # Deep merge so a nested override (e.g. system.idle.lock.timeout) keeps
      # the user's GUI-set sibling keys instead of replacing the whole object.
      jq --argjson overrides "$overrides" '${mergeJq}' "$file" >"$file.tmp"
      mv "$file.tmp" "$file"
    else
      printf '%s\n' "$overrides" >"$file"
    fi
  '';

  # pinnedapps lives in the data dir, not the config dir (Config.qml).
  pinnedappsPatch = lib.optionalString (settings.pinnedapps or null != null) ''
    file="$data/pinnedapps.json"
    overrides=${lib.escapeShellArg (builtins.toJSON settings.pinnedapps)}
    if [ -s "$file" ]; then
      jq --argjson overrides "$overrides" '${mergeJq}' "$file" >"$file.tmp"
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
      data="${config.xdg.dataHome}/pangu"
      mkdir -p "$conf" "$data"

      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList mkPatch (builtins.removeAttrs settings [ "pinnedapps" ])
      )}

      ${pinnedappsPatch}
    '';
  };
in
lib.mkIf cfg.enable {
  home.packages = [ pkgs.pangu ];

  assertions = [
    {
      assertion = builtins.all (name: builtins.elem name validFiles) (builtins.attrNames settings);
      message = ''
        mySystem.desktop.shell.settings uses unknown config file(s):
        ${lib.concatStringsSep ", " (
          builtins.filter (name: !builtins.elem name validFiles) (builtins.attrNames settings)
        )}
        Valid files: ${lib.concatStringsSep ", " validFiles}
      '';
    }
  ];

  systemd.user.services.pangu = import ../lib/autostart.nix {
    description = "Pangu — desktop shell";
    execStart = lib.getExe pkgs.pangu;
    unit.ConditionEnvironment = "WAYLAND_DISPLAY";
    service = {
      ExecStartPre = lib.getExe applySettings;
      RuntimeDirectory = "pangu";
      Slice = "session.slice";
      Environment = [ "PANGU_WALLPAPERS='${cfg.wallpapers}'" ];
    };
  };
}
