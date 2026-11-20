{ inputs, lib, ... }:

{
  imports = [ inputs.deltatune.homeManagerModules.default ];

  services.deltatune.enable = true;

  systemd.user.services.deltatune = (import ../lib/autostart.nix).bindSession {
    inherit lib;
    extraAfter = [
      "pipewire.service"
      "wireplumber.service"
    ];
  };
}
