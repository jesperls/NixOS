{
  pkgs,
  osConfig,
  ...
}:

let
  hyprlandTarget = "hyprland-session.target";

  cursorTheme = osConfig.mySystem.theme.gtk.cursorTheme;
  graphicalEnv = [
    "XCURSOR_THEME=${cursorTheme.name}"
    "XCURSOR_SIZE=${toString cursorTheme.size}"
    "HYPRCURSOR_THEME=${cursorTheme.name}"
    "HYPRCURSOR_SIZE=${toString cursorTheme.size}"
  ];

  mkAutostart =
    {
      description,
      execStart,
      unit ? { },
      service ? { },
    }:
    {
      Unit = {
        Description = description;
        After = [ hyprlandTarget ];
        PartOf = [ hyprlandTarget ];
      }
      // unit;
      Service = {
        ExecStart = execStart;
        Restart = "on-failure";
        RestartSec = 2;
      }
      // service;
      Install.WantedBy = [ hyprlandTarget ];
    };
in
{
  systemd.user.services = {
    qpwgraph = mkAutostart {
      description = "qpwgraph — PipeWire graph (minimized)";
      execStart = "${pkgs.qpwgraph}/bin/qpwgraph -m";
      unit.After = [
        hyprlandTarget
        "pipewire.service"
      ];
      service.Environment = graphicalEnv;
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
