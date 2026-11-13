{ inputs, lib, ... }:

{
  imports = [ inputs.deltatune.homeManagerModules.default ];

  services.deltatune.enable = true;

  systemd.user.services.deltatune = {
    Unit = {
      After = lib.mkForce [
        "hyprland-session.target"
        "pipewire.service"
        "wireplumber.service"
      ];
      PartOf = lib.mkForce [ "hyprland-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service.Slice = "session.slice";
    Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
  };
}
