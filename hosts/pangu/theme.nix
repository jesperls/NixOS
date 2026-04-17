{ pkgs, ... }:

{
  mySystem.theme = {
    name = "Obsidian Mocha";
    borders = 0;
    gaps = {
      inner = 4;
      outer = 8;
    };
    rounding = 25;
    colors = {
      accent = "#a869a8";
      accent2 = "#e3b17a";
      background = "#000000";
      surface = "#291825";
      surfaceAlt = "#13141a";
      text = "#e6e3e8";
      muted = "#b3adb9";
      border = "#2a2d36";
      shadow = "#08090d";
      activeBorder = "#a869a8";
      inactiveBorder = "#291825";
    };
    opacity = {
      activeBorder = "ee";
      inactiveBorder = "aa";
    };
    borderGradient = {
      enable = false;
      secondColor = "#e3b17a";
      angle = 45;
    };
    gtk = {
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };
    };
    qt = {
      styleName = "adwaita-dark";
      stylePackage = pkgs.adwaita-qt;
      platform = {
        name = "gtk";
        package = null;
      };
    };
  };
}
