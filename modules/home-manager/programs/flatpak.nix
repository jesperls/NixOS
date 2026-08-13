{
  config,
  lib,
  osConfig,
  ...
}:

lib.mkIf osConfig.mySystem.services.flatpak.enable {
  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];
}
