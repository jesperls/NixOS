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

  overridePaths =
    prefix: value:
    if builtins.isAttrs value then
      lib.concatLists (lib.mapAttrsToList (name: child: overridePaths (prefix ++ [ name ]) child) value)
    else
      [ (lib.concatStringsSep "." prefix) ];
  overrideMetadata = pkgs.writeText "pangu-nix-overrides.json" (
    builtins.toJSON (overridePaths [ ] settings)
  );

  configQml = builtins.readFile ../../../share/shell/config/Config.qml;
  validFiles = builtins.concatLists (
    builtins.filter builtins.isList (builtins.split "ConfigFile[^}]*name: \"([a-z]+)\"" configQml)
  );

  applySettings = import ../lib/apply-shell-settings.nix {
    inherit pkgs lib settings;
    configDir = "${config.xdg.configHome}/pangu/config";
    dataDir = "${config.xdg.dataHome}/pangu";
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
      ExecStartPre = [
        "-${lib.getExe' pkgs.systemd "systemctl"} --user stop wallpaperengine-*.service" # Stop renderers detached by older shell versions.
        (lib.getExe applySettings)
      ];
      RuntimeDirectory = "pangu";
      Slice = "session.slice";
      Environment = [
        "PANGU_WALLPAPERS='${cfg.wallpapers}'"
        "PANGU_NIX_OVERRIDES=${overrideMetadata}"
      ];
    };
  };
}
