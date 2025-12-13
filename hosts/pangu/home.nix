{ config, pkgs, osConfig, inputs, lib, ... }:

{
  imports = [
    ../../modules/home-manager/packages.nix
    ../../modules/home-manager/hyprland.nix
    ../../modules/home-manager/theme.nix
    ../../modules/home-manager/cli.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/caelestia.nix
    ../../modules/home-manager/spicetify.nix
    ../../modules/home-manager/deltatune.nix
    ../../modules/home-manager/mimeapps.nix
  ];

  home.sessionVariables = {
    ELECTRON_ENABLE_NG_MODULES = "true";
    BROWSER = "zen";
    DEFAULT_BROWSER = "zen";
    XDG_DATA_DIRS = lib.concatStringsSep ":" [
      "${config.home.homeDirectory}/.nix-profile/share"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
      "/var/lib/flatpak/exports/share"
      "$XDG_DATA_DIRS"
    ];
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    WLR_NO_HARDWARE_CURSORS = "1";
    GTK_USE_PORTAL = "1";
  };

  home.stateVersion = osConfig.mySystem.system.stateVersion;
}
