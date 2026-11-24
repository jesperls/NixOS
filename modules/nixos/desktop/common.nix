{
  config,
  lib,
  pkgs,
  ...
}:

{
  mySystem.performance.earlyoom = {
    preferRegex = lib.mkDefault "^(wine(64)?|wine-preloader|wine64-preloade|wineserver|Battle[.]net|lutris-wrapper)$|[.]exe$"; # [.] survives systemd Environment= unescaping
    avoidRegex = lib.mkDefault "^(Hyprland|[.]Hyprland-wrapp|pipewire|wireplumber|qs|[.]qs-wrapped|pangu)$|quickshell"; # comm is truncated to 15 bytes
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;
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
