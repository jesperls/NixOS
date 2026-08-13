{
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  mkAutostart = args: import ../lib/autostart.nix args;

  cursorEnv = (import ../lib/cursor.nix { inherit lib osConfig; }).env;
in
{
  systemd.user.services = {
    qpwgraph = mkAutostart {
      description = "qpwgraph — PipeWire graph (minimized)";
      execStart = "${pkgs.qpwgraph}/bin/qpwgraph -m";
      unit.After = [
        "hyprland-session.target"
        "pipewire.service"
      ];
      service.Environment = cursorEnv;
    };

    hyprpolkitagent = mkAutostart {
      description = "hyprpolkitagent — polkit authentication agent";
      execStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      unit.ConditionEnvironment = "WAYLAND_DISPLAY";
      service = {
        Slice = "session.slice";
        TimeoutStopSec = "5sec";
      };
    };

    networkmanagerapplet = mkAutostart {
      description = "nm-applet — NetworkManager tray applet";
      execStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
      unit.ConditionEnvironment = "WAYLAND_DISPLAY";
    };
  };
}
