{
  pkgs,
  osConfig,
  lib,
  ...
}:

let
  hyprSettings = import ./hyprland/settings.nix {
    inherit
      lib
      osConfig
      ;
  };

  hyprBinds = import ./hyprland/binds.nix {
    inherit lib osConfig;
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = lib.mkMerge [
      (import ./hyprland/variables.nix)
      hyprSettings.settings
      hyprBinds
      (import ./hyprland/windowrules.nix)
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
