{ config, lib, pkgs, ... }:

{
  networking.hostName = config.mySystem.system.hostName;
  networking.networkmanager.enable = true;
}
