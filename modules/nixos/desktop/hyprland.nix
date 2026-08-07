{ pkgs, ... }:

{
  security.polkit.enable = true;

  programs.hyprland.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.OpenURI" = [
          "gtk"
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    pamixer
    brightnessctl
  ];
}
