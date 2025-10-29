{ config, lib, pkgs, ... }:

{
  # Enable Bluetooth
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

  # Bluetooth services
  services.blueman.enable = true;

  # Additional Bluetooth packages
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    blueman
  ];
}