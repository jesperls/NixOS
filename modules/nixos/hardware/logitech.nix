{ ... }:

{
  programs.solaar = {
    enable = true;
    userService = {
      enable = true;
      extraArgs = [ "--restart-on-wake-up" ];
    };
  };

  systemd.user.services.solaar = {
    after = [ "graphical-session.target" ];
    unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
    serviceConfig.Slice = "session.slice";
  };
}
