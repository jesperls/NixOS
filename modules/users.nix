{ config, lib, pkgs, ... }:

{
  users.users.jesperls = {
    isNormalUser = true;
    description = "Jesper Lönn Stråle";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
  };

  services.getty.autologinUser = "jesperls";
}
