# Builds a systemd user unit tied to the Hyprland session, so autostarts stop
# with the session instead of lingering in the user manager.
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
