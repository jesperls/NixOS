{ config, ... }:

let
  themeFonts = config.mySystem.theme.fonts;
in
{
  fonts.fontconfig.enable = true;
  fonts.packages = themeFonts.packages;

  fonts.fontconfig.defaultFonts = {
    monospace = [
      themeFonts.monospace
      "Noto Sans Mono"
    ];
    sansSerif = [
      themeFonts.sans
      "Noto Sans"
    ];
    serif = [ "Noto Serif" ];
    emoji = [ "Noto Color Emoji" ];
  };
}
