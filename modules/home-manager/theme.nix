{ config, lib, pkgs, osConfig, ... }:

let
  theme = osConfig.mySystem.theme;
  colors = theme.colors;

in
{
  gtk = {
    enable = true;
    theme = {
      name = theme.gtk.theme.name;
      package = theme.gtk.theme.package;
    };
    iconTheme = theme.gtk.iconTheme;
    cursorTheme = {
      inherit (theme.gtk.cursorTheme) name package size;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-button-images = 1;
      gtk-menu-images = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
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
  };

  home.sessionVariables = {
    GTK_THEME = "${theme.gtk.theme.name}:dark";
    GTK_THEME_VARIANT = "dark";
    QT_STYLE_OVERRIDE = theme.qt.styleName;
    QT_QPA_PLATFORMTHEME = lib.mkForce theme.qt.platform.name;
    XCURSOR_THEME = theme.gtk.cursorTheme.name;
    XCURSOR_SIZE = builtins.toString theme.gtk.cursorTheme.size;
  };
}
