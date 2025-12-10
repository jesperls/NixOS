{ config, lib, pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals =
      [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
    config = { common = { default = [ "hyprland" "gtk" ]; }; };
  };

  environment.systemPackages = with pkgs; [
    pamixer
    brightnessctl
    gpu-screen-recorder
  ];

  security.wrappers.gsr-kms-server = {
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
  };
}
