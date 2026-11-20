{
  mkService =
    {
      description,
      execStart,
      target ? "hyprland-session.target",
      unit ? { },
      service ? { },
    }:
    {
      Unit = {
        Description = description;
        After = [ target ];
        BindsTo = [ target ];
        PartOf = [ target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      }
      // unit;

      Service = {
        ExecStart = execStart;
        Restart = "on-failure";
        RestartSec = 2;
        Slice = "session.slice";
      }
      // service;

      Install.WantedBy = [ target ];
    };

  bindSession =
    {
      lib,
      target ? "hyprland-session.target",
      extraAfter ? [ ],
      unit ? { },
      service ? { },
    }:
    {
      Unit = {
        After = lib.mkForce ([ target ] ++ extraAfter);
        BindsTo = lib.mkForce [ target ];
        PartOf = lib.mkForce [ target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      }
      // unit;

      Service = {
        Slice = "session.slice";
      }
      // service;

      Install.WantedBy = lib.mkForce [ target ];
    };
}
