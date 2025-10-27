{ config, pkgs, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    hyprcursor.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Noto Sans";
      size = 11;
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        "gtk-theme" = "Arc-Dark";
        "icon-theme" = "Papirus-Dark";
        "font-name" = "Noto Sans 11";
        "color-scheme" = "prefer-dark";
      };
    };
  };

  home.sessionVariables = { GTK_THEME = "Arc-Dark"; };
}
