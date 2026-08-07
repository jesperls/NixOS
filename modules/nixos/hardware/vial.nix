{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.hardware.vial;
in
{
  options.mySystem.hardware.vial.enable =
    lib.mkEnableOption "Vial keyboard configurator and QMK udev rules";

  config = lib.mkIf cfg.enable {
    services.udev.packages = with pkgs; [
      qmk-udev-rules
    ];

    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess"
    '';

    environment.systemPackages = with pkgs; [
      vial
    ];
  };
}
