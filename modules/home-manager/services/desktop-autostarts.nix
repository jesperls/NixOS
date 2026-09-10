{ pkgs, ... }:

{
  home.packages = [ pkgs.qpwgraph ];

  services.hyprpolkitagent.enable = true;
  services.network-manager-applet.enable = true;

  systemd.user.services = {
    hyprpolkitagent = {
      Unit.ConditionEnvironment = "WAYLAND_DISPLAY";
      Service = {
        Restart = "on-failure";
        RestartSec = 2;
        Slice = "session.slice";
        TimeoutStopSec = "5sec";
      };
    };

    network-manager-applet = {
      Unit.ConditionEnvironment = "WAYLAND_DISPLAY";
      Service = {
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };
}
