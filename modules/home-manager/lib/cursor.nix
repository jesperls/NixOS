{
  lib,
  osConfig,
}:

let
  theme = osConfig.mySystem.theme.gtk.cursorTheme;

  vars = {
    XCURSOR_THEME = theme.name;
    XCURSOR_SIZE = toString theme.size;
    HYPRCURSOR_THEME = theme.name;
    HYPRCURSOR_SIZE = toString theme.size;
  };
in
{
  inherit vars;
  env = lib.mapAttrsToList (name: value: "${name}=${value}") vars;
}
