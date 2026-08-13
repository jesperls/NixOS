{
  config,
  pkgs,
  osConfig,
  ...
}:

let
  apps = osConfig.mySystem.defaultApps;
in
{
  home.sessionVariables = {
    BROWSER = apps.browser.command;
    DEFAULT_BROWSER = apps.browser.command;
    TERMINAL = apps.terminal.command;

    GDK_BACKEND = "wayland,x11,*";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";

    GTK_USE_PORTAL = "1";

    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    UV_PYTHON_PREFERENCE = "managed";

    FLAKE = osConfig.mySystem.paths.repoRoot;
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share"
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
  ];
}
