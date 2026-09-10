{ config, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  programs.dconf.enable = true;
  xdg.mime.enable = true;
  xdg.terminal-exec = {
    enable = true;
    settings.default = [ config.mySystem.defaultApps.terminal.desktopFile ];
  };
  services.upower.enable = true;
}
