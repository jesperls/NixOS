{ config, pkgs, ... }:

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

  programs.nix-ld.libraries = with pkgs; [
    libICE
    libSM
    libXext
    vulkan-loader
    libGL
    libxkbcommon
    fontconfig
    freetype
    libx11
    libxcursor
    libxrandr
    libxi
    libxcb
    xcbutilwm
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilcursor
    wayland
    qt6.qtwayland
    alsa-lib
  ];
}
