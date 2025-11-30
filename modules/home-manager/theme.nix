{ config, pkgs, osConfig, ... }:

let
  # GTK theme configuration
  gtkThemeName = "catppuccin-mocha-blue-standard";
  gtkThemePackage = pkgs.catppuccin-gtk.override {
    accents = [ "blue" ];
    size = "standard";
    variant = "mocha";
  };

  # Icon theme configuration
  iconThemeName = "Papirus-Dark";
  iconThemePackage = pkgs.papirus-icon-theme;

  # Font configuration from system theme
  fontName = osConfig.mySystem.theme.fonts.default;
  fontSize = osConfig.mySystem.theme.fonts.size;
in {

  # Cursor theme
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    hyprcursor.enable = true;
  };

  # GTK theming
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

    gtk3.bookmarks = [ "file://${config.home.homeDirectory}/Downloads" ];
  };

  # GNOME dconf settings
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

  # XFCE settings
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

  # Qt theming
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  home.packages = [ gtkThemePackage iconThemePackage ];

  home.sessionVariables = { GTK_THEME = gtkThemeName; };
}
