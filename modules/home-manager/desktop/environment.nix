{
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
    NIXOS_OZONE_WL = "1";

    GTK_USE_PORTAL = "1";

    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
}
