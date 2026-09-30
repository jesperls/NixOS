{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  fontState = pkgs.writeText "flatpak-font-state" (
    builtins.toJSON {
      packages = map toString osConfig.fonts.packages;
      config = toString osConfig.environment.etc.fonts.source;
    }
  );
in
{
  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
  ];

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
