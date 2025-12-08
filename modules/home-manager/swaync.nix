{ config, pkgs, osConfig, ... }:

let
  colors = osConfig.mySystem.theme.colors;
  fonts = osConfig.mySystem.theme.fonts;
in {
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      layer-shell-cover-screen = false;
      ignore-gtk-theme = true;
      cssPriority = "user";
      control-center-margin-top = 0;
      control-center-margin-bottom = 0;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
    };
    style = import ./swaync/style.nix { inherit fonts colors; };
  };
}
