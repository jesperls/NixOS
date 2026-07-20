{ pkgs, inputs, ... }:

let
  hyprnix = inputs.hyprnix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  security.polkit.enable = true;

  programs.hyprland = {
    enable = true;
    package = hyprnix.hyprland;
    portalPackage = hyprnix.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;
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
    hyprpolkitagent
    pamixer
    brightnessctl
  ];
}
