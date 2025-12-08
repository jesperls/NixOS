{ config, pkgs, osConfig, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = lib.mkMerge [
      (import ./hyprland/variables.nix { })
      (import ./hyprland/settings.nix { inherit config pkgs lib osConfig; })
      (import ./hyprland/binds.nix { })
      (import ./hyprland/windowrules.nix { })
    ];
  };

  # Hyprland portal configuration for screensharing
  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';

  # Hyprland-related user packages
  home.packages = with pkgs; [
    # Hyprland ecosystem packages
    hyprland-protocols
    hyprwayland-scanner
    hyprutils
    hyprgraphics
    hyprlang
    hyprcursor
    aquamarine
    hyprpolkitagent

    # Desktop portals (user-level installation)
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];
}
