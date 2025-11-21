{ config, lib, pkgs, ... }:

{
  users.users.${config.mySystem.user.username} = {
    isNormalUser = true;
    description = config.mySystem.user.fullName;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  services.getty.autologinUser = config.mySystem.user.username;
}
