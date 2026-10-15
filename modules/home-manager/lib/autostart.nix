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
}
