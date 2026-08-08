{
  config,
  lib,
  ...
}:

let
  cfg = config.mySystem.services.flatpak;
in
{
  options.mySystem.services.flatpak.enable =
    lib.mkEnableOption "the Flatpak daemon and portal integration";

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
  };
}
