{ config, pkgs, osConfig, inputs, ... }:

let
  caelestiaShellPatched =
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}."with-cli".overrideAttrs
    (old: {
      prePatch = (old.prePatch or "") + ''
        substituteInPlace services/GameMode.qml \
          --replace '"general:border_size": 1' '"general:border_size": 0'
        substituteInPlace services/Recorder.qml \
          --replace 'property list<string> startArgs' 'property list<string> startArgs: []' \
          --replace 'function start(extraArgs: list<string>): void {' 'function start(extraArgs = []) {'
        substituteInPlace services/Notifs.qml \
          --replace 'notif.tracked = true;' 'const app = (notif.appName || "").toLowerCase(); if (app.includes("spotify")) return; notif.tracked = true;'
      '';
    });
  spicePkgs =
    inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [
    ../../modules/home-manager/packages.nix
    ../../modules/home-manager/hyprland.nix
    ../../modules/home-manager/theme.nix
    ../../modules/home-manager/cli.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/mimeapps.nix
    inputs.caelestia-shell.homeManagerModules.default
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    package = caelestiaShellPatched;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
    cli.enable = true;
    settings = {
      appearance = { anim = { durations = { scale = 0.4; }; }; };
      background = { enabled = false; };
      paths.wallpaperDir = "~/Pictures/Wallpapers";
      bar.status = {
        showBattery = false;
        showAudio = true;
      };
      general = {
        apps = { explorer = [ "thunar" ]; };
        idle = {
          lockBeforeSleep = false;
          timeouts = [ ];
        };
      };
    };
  };

  programs.spicetify = { enable = true; };

  home.sessionVariables = {
    ELECTRON_ENABLE_NG_MODULES = "true";
    BROWSER = "zen";
    DEFAULT_BROWSER = "zen";
    XDG_DATA_DIRS =
      "${config.home.homeDirectory}/.nix-profile/share:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${config.home.homeDirectory}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS";
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
