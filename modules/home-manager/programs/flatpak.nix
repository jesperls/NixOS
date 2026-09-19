{
  config,
  lib,
  ...
}:

{
  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];

  home.activation.clearFlatpakFontCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for cache in "${config.home.homeDirectory}"/.var/app/*/cache/fontconfig; do
      if [ -d "$cache" ]; then rm -rf "$cache"; fi
    done
  '';
}
