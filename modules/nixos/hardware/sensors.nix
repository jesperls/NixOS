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
  options.mySystem.hardware.sensors = {
    enable = lib.mkEnableOption "motherboard sensor modules and monitoring tools";

    modules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "k10temp"
        "nct6775"
      ];
      description = "Kernel modules for the motherboard's sensor chips.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = cfg.modules;

    # ddcutil in the shell reads monitor brightness over the i2c bus.
    hardware.i2c.enable = true;

    environment.systemPackages = with pkgs; [
      lm_sensors
      nvtopPackages.full
    ];
  };
}
