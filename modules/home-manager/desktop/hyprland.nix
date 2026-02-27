{
  config,
  pkgs,
  osConfig,
  lib,
  inputs,
  ...
}:

let
  hyprnix = inputs.hyprnix.packages.${pkgs.stdenv.hostPlatform.system};

  hyprSettings = import ./hyprland/settings.nix {
    inherit
      config
      pkgs
      lib
      osConfig
      ;
  };

  hyprPlugins = [
    # hyprnix.hyprexpo
    # hyprnix.hyprtrails
    # hyprnix.hypr-dynamic-cursors
  ];
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprnix.hyprland;
    portalPackage = hyprnix.xdg-desktop-portal-hyprland;
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
