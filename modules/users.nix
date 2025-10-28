{ config, lib, pkgs, userConfig, ... }:

{
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.fullName;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
  };

  services.getty.autologinUser = userConfig.username;
}
