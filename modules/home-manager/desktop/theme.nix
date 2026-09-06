{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  theme = osConfig.mySystem.theme;
  cursor = theme.gtk.cursorTheme;

  hyprcursorTheme =
    pkgs.runCommand "${cursor.name}-hyprcursor"
      {
        nativeBuildInputs = [
          pkgs.hyprcursor
          pkgs.xcur2png
        ];
      }
      ''
        hyprcursor-util --extract ${cursor.package}/share/icons/${cursor.name} --output .
        substituteInPlace "extracted_${cursor.name}/manifest.hl" \
          --replace-fail "name = Extracted Theme" "name = ${cursor.name}"
        hyprcursor-util --create extracted_${cursor.name} --output .
        mkdir -p $out/share/icons
        cp -r "theme_${cursor.name}" $out/share/icons/${cursor.name}
      '';

  shellPalette = osConfig.mySystem.desktop.shell.enable;

  qtctSettings = ver: {
    Appearance = {
      style = theme.qt.style;
      custom_palette = shellPalette;
      icon_theme = theme.gtk.iconTheme.name;
      standard_dialogs = "xdgdesktopportal";
    }
    // lib.optionalAttrs shellPalette {
      color_scheme_path = "${config.home.homeDirectory}/.config/${ver}/colors/pangu.colors";
    };
    Fonts = {
      general = ''"${theme.fonts.sans},${toString theme.fonts.size}"'';
      fixed = ''"${theme.fonts.monospace},${toString theme.fonts.size}"'';
    };
  };
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
    font = {
      name = theme.fonts.sans;
      size = theme.fonts.size;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    qt5ctSettings = qtctSettings "qt5ct";
    qt6ctSettings = qtctSettings "qt6ct";
  };

  home.pointerCursor = {
    enable = true;
    name = theme.gtk.cursorTheme.name;
    package = theme.gtk.cursorTheme.package;
    size = theme.gtk.cursorTheme.size;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = [
    theme.gtk.iconTheme.package
    hyprcursorTheme
    pkgs.hicolor-icon-theme
    pkgs.adwaita-icon-theme
    pkgs.libappindicator-gtk3
  ];

  dconf.settings."org/gnome/desktop/interface" = {
    icon-theme = theme.gtk.iconTheme.name;
    gtk-theme = theme.gtk.theme.name;
    cursor-theme = theme.gtk.cursorTheme.name;
    cursor-size = theme.gtk.cursorTheme.size;
    color-scheme = lib.mkIf (!shellPalette) "prefer-dark";
    font-name = "${theme.fonts.sans} ${toString theme.fonts.size}";
    monospace-font-name = "${theme.fonts.monospace} ${toString theme.fonts.size}";
  };
}
