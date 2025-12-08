{ config, pkgs, osConfig, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    extraConfig = {
      modi = "drun,run,filebrowser,window";
      icon-theme = "Papirus-Dark";
      show-icons = true;
      terminal = "kitty";
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-window = " 󰕰  Window";
      display-Network = " 󰤨  Network";
      sidebar-mode = true;
    };

    theme = import ./rofi/theme.nix {
      inherit config;
      theme = osConfig.mySystem.theme;
    };
  };
}
