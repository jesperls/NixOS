{ lib, ... }:

{
  services.hyprpolkitagent.enable = true;

  systemd.user.services.hyprpolkitagent = {
    Unit = {
      After = lib.mkForce [ "hyprland-session.target" ];
      BindsTo = lib.mkForce [ "hyprland-session.target" ];
      PartOf = lib.mkForce [ "hyprland-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      Restart = "on-failure";
      RestartSec = 2;
      Slice = "session.slice";
      TimeoutStopSec = "5sec";
    };
    Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
  };
}
