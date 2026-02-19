{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  theme = osConfig.mySystem.theme;
in
{
  gtk = {
    enable = true;
    theme = {
      name = theme.gtk.theme.name;
      package = theme.gtk.theme.package;
    };
    iconTheme = theme.gtk.iconTheme;
    cursorTheme = { inherit (theme.gtk.cursorTheme) name package size; };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme = {
      name = theme.qt.platform.name;
      package = theme.qt.platform.package;
    };
    style = {
      name = theme.qt.styleName;
      package = theme.qt.stylePackage;
    };
  };

  home.pointerCursor = {
    name = theme.gtk.cursorTheme.name;
    package = theme.gtk.cursorTheme.package;
    size = theme.gtk.cursorTheme.size;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = [
    theme.gtk.iconTheme.package
    pkgs.hicolor-icon-theme
    pkgs.adwaita-icon-theme
    pkgs.libappindicator-gtk3
  ];

  dconf.settings."org/gnome/desktop/interface" = {
    icon-theme = theme.gtk.iconTheme.name;
    gtk-theme = theme.gtk.theme.name;
    cursor-theme = theme.gtk.cursorTheme.name;
    cursor-size = theme.gtk.cursorTheme.size;
    color-scheme = "prefer-dark";
  };
}
