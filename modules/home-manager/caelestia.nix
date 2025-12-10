{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  caelestiaShellPatched =
    inputs.caelestia-shell.packages.${system}."with-cli".overrideAttrs (old: {
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
in {
  imports = [ inputs.caelestia-shell.homeManagerModules.default ];

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
}
