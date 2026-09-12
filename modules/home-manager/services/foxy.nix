{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  foxy = inputs.foxy.packages.${pkgs.stdenv.hostPlatform.system}.foxy;
in
{
  home.packages = [ foxy ];

  systemd.user.services.foxy = import ../lib/autostart.nix {
    description = "Foxy — jumpscare overlay";
    execStart = lib.getExe foxy;
    unit.ConditionEnvironment = "WAYLAND_DISPLAY";
    service.Slice = "session.slice";
  };
}
