{
  inputs,
  osConfig,
  config,
  ...
}:

let
  lockscreen = osConfig.mySystem.desktop.lockscreen;
in
{
  imports = [ inputs.caelestia-shell.homeManagerModules.default ];

  programs.caelestia = {
    enable = true;
    systemd.enable = true;
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
      border.thickness = osConfig.mySystem.theme.borders;
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
}
