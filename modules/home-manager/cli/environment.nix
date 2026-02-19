{
  config,
  pkgs,
  osConfig,
  ...
}:

let
  theme = osConfig.mySystem.theme;
in
{
  home.sessionVariables = {
    # === Browser ===
    BROWSER = "firefox";
    DEFAULT_BROWSER = "firefox";

    # === Wayland / Display ===
    GDK_BACKEND = "wayland,x11,*";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";

    # === XDG / Desktop ===
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GTK_USE_PORTAL = "1";
    DISABLE_WAYLAND_IDLE_INHIBIT = "1";

    # === Electron ===
    ELECTRON_ENABLE_NG_MODULES = "true";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # === Theme ===
    GTK_THEME = theme.gtk.theme.name;
    XCURSOR_THEME = theme.gtk.cursorTheme.name;
    XCURSOR_SIZE = builtins.toString theme.gtk.cursorTheme.size;
    ICON_THEME = theme.gtk.iconTheme.name;

    # === Python / uv ===
    UV_PYTHON_PREFERENCE = "managed";
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    LD_LIBRARY_PATH = "${pkgs.portaudio}/lib";

    # === Audio / TTS ===
    PHONEMIZER_ESPEAK_LIBRARY = "${pkgs.espeak-ng}/lib/libespeak-ng.so";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share"
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];
}
