{ config, pkgs, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/user-apps.nix
    ./modules/hyprland.nix
    ./modules/wallpaper.nix
    ./modules/waybar.nix
    ./modules/gtk.nix
    ./modules/programs.nix
    ./modules/zsh.nix
    ./modules/rofi.nix
    ./modules/swaync.nix
    ./modules/mimeapps.nix
  ];

  home.sessionVariables = {
    ELECTRON_ENABLE_NG_MODULES = "true";
    BROWSER = "firefox";
    DEFAULT_BROWSER = "firefox";
    XDG_DATA_DIRS =
      "${config.home.homeDirectory}/.nix-profile/share:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    WLR_NO_HARDWARE_CURSORS = "1";
    GTK_USE_PORTAL = "1";
  };

  home.stateVersion = "25.05";
}
