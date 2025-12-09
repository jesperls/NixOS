{ config, pkgs, osConfig, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/packages.nix
    ../../modules/home-manager/hyprland.nix
    ../../modules/home-manager/theme.nix
    ../../modules/home-manager/cli.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/mimeapps.nix
    inputs.caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    package =
      inputs.caelestia-shell.packages.${pkgs.system}.default.overrideAttrs
      (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace components/filedialog/FolderContents.qml \
            --replace "model: FileSystemModel {" "model: FileSystemModel { showHidden: true;"
        '';
      });
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
    cli.enable = true;
    settings = {
      appearance = { anim = { durations = { scale = 0.4; }; }; };
      background = { enabled = false; };
      general = { apps = { explorer = [ "thunar" ]; }; };
    };
  };

  home.packages = [
    (pkgs.callPackage "${inputs.caelestia-shell}/nix/app2unit.nix" {
      inherit pkgs;
    })
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

  home.stateVersion = osConfig.mySystem.system.stateVersion;
}
