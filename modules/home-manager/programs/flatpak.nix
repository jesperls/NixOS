{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cursor = osConfig.mySystem.theme.gtk.cursorTheme;
  iconTheme = osConfig.mySystem.theme.gtk.iconTheme;
  fontState = pkgs.writeText "flatpak-font-state" (
    builtins.toJSON {
      packages = map toString osConfig.fonts.packages;
      config = toString osConfig.environment.etc.fonts.source;
    }
  );
in
{
  xdg.dataFile."flatpak/overrides/global".text = ''
    [Context]
    filesystems=xdg-config/gtk-3.0:ro;xdg-config/gtk-4.0:ro;xdg-cache/pangu:ro;~/.icons:ro;xdg-data/icons:ro;${cursor.package}/share/icons:ro;${iconTheme.package}/share/icons:ro;

    [Environment]
    XCURSOR_THEME=${cursor.name}
    XCURSOR_SIZE=${toString cursor.size}
    XCURSOR_PATH=${cursor.package}/share/icons
  '';

  home.activation.clearFlatpakFontCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    fontStateFile=${lib.escapeShellArg "${config.xdg.stateHome}/flatpak/fonts"}
    if ! ${pkgs.diffutils}/bin/cmp -s ${fontState} "$fontStateFile"; then
      for cache in ${lib.escapeShellArg config.home.homeDirectory}/.var/app/*/cache/fontconfig; do
        if [ -d "$cache" ]; then run rm -rf -- "$cache"; fi
      done
      run ${pkgs.coreutils}/bin/install -Dm600 -- ${fontState} "$fontStateFile"
    fi
  '';
}
