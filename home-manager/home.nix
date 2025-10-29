{ config, pkgs, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/user-apps.nix
    ./modules/hyprland.nix
    ./modules/gtk.nix
    ./modules/programs.nix
    ./modules/mimeapps.nix
  ];

  home.sessionVariables = { 
    ELECTRON_ENABLE_NG_MODULES = "true";
    BROWSER = "firefox";
    DEFAULT_BROWSER = "firefox";
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.nix-profile/share";
  };

  home.stateVersion = "25.05";
}
