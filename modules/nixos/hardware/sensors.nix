{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.hardware.sensors;
in
{
  options.mySystem.hardware.sensors.enable =
    lib.mkEnableOption "motherboard sensor modules and monitoring tools";

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [
      "k10temp"
      "nct6775"
    ];

    environment.systemPackages = with pkgs; [
      lm_sensors
      nvtopPackages.full
    ];
  };
}
