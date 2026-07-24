{
  pkgs,
  osConfig,
  ...
}:

let
  mkAutostart = args: import ../lib/autostart.nix args;

  cursorTheme = osConfig.mySystem.theme.gtk.cursorTheme;
  cursorEnv = [
    "XCURSOR_THEME=${cursorTheme.name}"
    "XCURSOR_SIZE=${toString cursorTheme.size}"
    "HYPRCURSOR_THEME=${cursorTheme.name}"
    "HYPRCURSOR_SIZE=${toString cursorTheme.size}"
  ];
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
  };
}
