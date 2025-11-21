{ config, pkgs, ... }:

let
  gtkThemeName = "catppuccin-mocha-blue-standard";
  gtkThemePackage = pkgs.catppuccin-gtk.override {
    accents = [ "blue" ];
    size = "standard";
    variant = "mocha";
  };

  iconThemeName = "Papirus-Dark";
  iconThemePackage = pkgs.papirus-icon-theme;

  fontName = "Noto Sans";
  fontSize = 11;
in {
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
      name = gtkThemeName;
      package = gtkThemePackage;
    };

    iconTheme = {
      name = iconThemeName;
      package = iconThemePackage;
    };

    font = {
      name = fontName;
      size = fontSize;
    };

    gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };

    gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; };

    gtk3.bookmarks = [
      "file://${config.home.homeDirectory}/Documents"
      "file://${config.home.homeDirectory}/Downloads"
      "file://${config.home.homeDirectory}/Pictures"
      "file://${config.home.homeDirectory}/Videos"
      "file://${config.home.homeDirectory}/Music"
    ];
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = gtkThemeName;
        icon-theme = iconThemeName;
        font-name = "${fontName} ${toString fontSize}";
        color-scheme = "prefer-dark";
      };
    };
  };

  xfconf = {
    enable = true;
    settings = {
      xsettings = {
        "Net/ThemeName" = gtkThemeName;
        "Net/IconThemeName" = iconThemeName;
        "Gtk/FontName" = "${fontName} ${toString fontSize}";
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  home.packages = [ gtkThemePackage iconThemePackage ];

  home.sessionVariables = { GTK_THEME = gtkThemeName; };
}
