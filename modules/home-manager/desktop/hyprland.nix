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

  hyprPlugins = [
    pkgs.hyprlandPlugins.hyprexpo
    pkgs.hyprlandPlugins.hyprtrails
    pkgs.hyprlandPlugins.hypr-dynamic-cursors
  ];
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    plugins = hyprPlugins;
    settings = lib.mkMerge [
      (import ./hyprland/variables.nix { })
      hyprSettings.settings
      (import ./hyprland/plugins.nix {
        inherit
          lib
          osConfig
          ;
      })
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
    hyprpicker
  ];
}
