{ config, lib, pkgs, ... }:

with lib;

let cfg = config.mySystem.services.bluetooth;
in {
  options.mySystem.services.bluetooth = {
    enable = mkEnableOption "Bluetooth support";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    services.blueman.enable = true;
  };
}
