{
  config,
  pkgs,
  osConfig,
  ...
}:

let
  theme = osConfig.mySystem.theme;
  apps = osConfig.mySystem.defaultApps;
in
{
  home.sessionVariables = {
    # === Default applications ===
    BROWSER = apps.browser.command;
    DEFAULT_BROWSER = apps.browser.command;
    TERMINAL = apps.terminal.command;

    # === Wayland / Display ===
    GDK_BACKEND = "wayland,x11,*";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";

    # === XDG / Desktop ===
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

    # === Nix Helpers ===
    FLAKE = osConfig.mySystem.paths.repoRoot;
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share"
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
  ];
}
