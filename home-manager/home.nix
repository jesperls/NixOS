{ config, pkgs, zen-browser, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/hyprland.nix
    ./modules/gtk.nix
    ./modules/programs.nix
    ./modules/mimeapps.nix
  ];

  home.sessionVariables = { ELECTRON_ENABLE_NG_MODULES = "true"; };

  home.stateVersion = "25.05";
}
