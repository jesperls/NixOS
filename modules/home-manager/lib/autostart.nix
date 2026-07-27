{
  description,
  execStart,
  unit ? { },
  service ? { },
}:

let
  target = "hyprland-session.target";
in
{
  Unit = {
    Description = description;
    After = [ target ];
    PartOf = [ target ];
  }
  // unit;

  Service = {
    ExecStart = execStart;
    Restart = "on-failure";
    RestartSec = 2;
  }
  // service;

  Install.WantedBy = [ target ];
}
