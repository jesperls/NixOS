{
  inputs,
  osConfig,
  config,
  lib,
  ...
}:

let
  lockscreen = osConfig.mySystem.desktop.lockscreen;
in
{
  imports = [ inputs.caelestia-shell.homeManagerModules.default ];

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
    cli.enable = true;

    baseColors = osConfig.mySystem.theme.colors;

    settings = {
      appearance = {
        anim.durations.scale = 0.4;
      };
      background.enabled = false;
      paths.wallpaperDir = config.programs.wallpaperPicker.wallpaperDir;
      bar.status = {
        showBattery = true;
        showAudio = true;
        showWifi = false;
      };
      border.thickness = 1;
      general = {
        apps.explorer = [ "thunar" ];
        idle = {
          lockBeforeSleep = lockscreen.enable && lockscreen.lockOnSleep;
          timeouts = [ ];
        };
      };
      lock.hideNotifs = lockscreen.enable;
      services.smartScheme = false;
    };
  };

  wayland.windowManager.hyprland.settings.exec-once =
    lib.mkIf (lockscreen.enable && lockscreen.lockOnBoot)
      [
        "sleep 1 && caelestia-shell ipc --any-display call lock lock"
      ];
}
