{
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  theme = osConfig.mySystem.theme;
  colors = theme.colors;

  accentCss = ''
    @define-color accent_color ${colors.accent};
    @define-color accent_bg_color ${colors.accent};
    @define-color accent_fg_color ${colors.background};
  '';

  opaque = color: "#ff${lib.removePrefix "#" color}";

  # qt5ct/qt6ct color schemes are 21 comma-separated colors in this role order.
  roleOrder = [
    "WindowText"
    "Button"
    "Light"
    "Midlight"
    "Dark"
    "Mid"
    "Text"
    "BrightText"
    "ButtonText"
    "Base"
    "Window"
    "Shadow"
    "Highlight"
    "HighlightedText"
    "Link"
    "LinkVisited"
    "AlternateBase"
    "NoRole"
    "ToolTipBase"
    "ToolTipText"
    "PlaceholderText"
  ];
  mkRow = roles: lib.concatMapStringsSep ", " (role: opaque roles.${role}) roleOrder;

  activeRoles = {
    WindowText = colors.text;
    Button = colors.surface;
    Light = colors.border;
    Midlight = colors.border;
    Dark = colors.background;
    Mid = colors.border;
    Text = colors.text;
    BrightText = colors.text;
    ButtonText = colors.text;
    Base = colors.surfaceAlt;
    Window = colors.background;
    Shadow = colors.shadow;
    Highlight = colors.accent;
    HighlightedText = colors.background;
    Link = colors.accent2;
    LinkVisited = colors.accent;
    AlternateBase = colors.surface;
    NoRole = colors.surface;
    ToolTipBase = colors.surface;
    ToolTipText = colors.text;
    PlaceholderText = colors.muted;
  };

  disabledRoles = activeRoles // {
    WindowText = colors.muted;
    Text = colors.muted;
    BrightText = colors.muted;
    ButtonText = colors.muted;
    Highlight = colors.surface;
    HighlightedText = colors.muted;
    ToolTipText = colors.muted;
  };

  qtColorScheme = pkgs.writeText "mysystem-qt-palette.conf" ''
    [ColorScheme]
    active_colors=${mkRow activeRoles}
    disabled_colors=${mkRow disabledRoles}
    inactive_colors=${mkRow activeRoles}
  '';

  qtctSettings = {
    Appearance = {
      style = theme.qt.style;
      custom_palette = true;
      color_scheme_path = "${qtColorScheme}";
      icon_theme = theme.gtk.iconTheme.name;
      standard_dialogs = "xdgdesktopportal";
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
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk3.extraCss = accentCss;
    gtk4.extraCss = accentCss;
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    qt5ctSettings = qtctSettings;
    qt6ctSettings = qtctSettings;
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
