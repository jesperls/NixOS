{ lib, ... }:

{
  services.hyprpolkitagent.enable = true;

  systemd.user.services.hyprpolkitagent = (import ../lib/autostart.nix).bindSession {
    inherit lib;
    service = {
      Restart = "on-failure";
      RestartSec = 2;
      TimeoutStopSec = "5sec";
    };
  };
}
