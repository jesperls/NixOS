{
  config,
  pkgs,
  osConfig,
  inputs,
  lib,
  ...
}:

{
  imports = [
    ../../modules/home-manager/xdg.nix
    ../../modules/home-manager/theme.nix
    ../../modules/home-manager/mimeapps.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/cli.nix
    ../../modules/home-manager/hyprland.nix
    ../../modules/home-manager/packages.nix
    ../../modules/home-manager/vesktop.nix
    ../../modules/home-manager/caelestia.nix
    ../../modules/home-manager/spicetify.nix
    ../../modules/home-manager/deltatune.nix
    ../../modules/home-manager/obs.nix
  ];

  home.sessionVariables = {
    BROWSER = "zen";
    DEFAULT_BROWSER = "zen";

    ELECTRON_ENABLE_NG_MODULES = "true";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    GDK_BACKEND = "wayland,x11,*";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";

    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";

    GTK_USE_PORTAL = "1";

    WLR_NO_HARDWARE_CURSORS = "1";

    DISABLE_WAYLAND_IDLE_INHIBIT = "1";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  xdg.systemDirs.data = [
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];

  home.stateVersion = osConfig.mySystem.system.stateVersion;
}
