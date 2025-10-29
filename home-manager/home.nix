{ config, pkgs, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/user-apps.nix
    ./modules/hyprland.nix
    ./modules/waybar.nix
    ./modules/gtk.nix
    ./modules/programs.nix
    ./modules/mimeapps.nix
  ];

  home.sessionVariables = { 
    ELECTRON_ENABLE_NG_MODULES = "true";
    BROWSER = "firefox";
    DEFAULT_BROWSER = "firefox";
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.nix-profile/share";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  home.stateVersion = "25.05";
}
