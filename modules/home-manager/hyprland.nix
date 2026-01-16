{
  config,
  pkgs,
  osConfig,
  lib,
  ...
}:

let
  hyprSettings = import ./hyprland/settings.nix {
    inherit
      config
      pkgs
      lib
      osConfig
      ;
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = lib.mkMerge [
      (import ./hyprland/variables.nix { })
      hyprSettings.settings
      (import ./hyprland/binds.nix { })
      (import ./hyprland/windowrules.nix { })
    ];
  };

  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';

  home.packages = with pkgs; [
    hyprland-protocols
    hyprwayland-scanner
    hyprutils
    hyprgraphics
    hyprlang
    hyprcursor
    aquamarine
    hyprpolkitagent
    hyprpicker

    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];
}
