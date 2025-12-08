{ config, pkgs, osConfig, ... }:

{
  programs.waybar = {
    enable = true;
    settings = import ./waybar/settings.nix { };

    style = import ./waybar/style.nix { theme = osConfig.mySystem.theme; };
  };
}
