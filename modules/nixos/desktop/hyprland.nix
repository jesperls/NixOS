{ config, lib, pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals =
      [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
    config = { common = { default = [ "hyprland" "gtk" ]; }; };
  };

  environment.systemPackages = with pkgs; [ pamixer brightnessctl ];
}
