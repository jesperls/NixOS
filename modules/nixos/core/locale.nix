{ config, lib, ... }:

let
  cfg = config.mySystem.system;

  regionalCategories = [
    "LC_ADDRESS"
    "LC_IDENTIFICATION"
    "LC_MEASUREMENT"
    "LC_MONETARY"
    "LC_NAME"
    "LC_NUMERIC"
    "LC_PAPER"
    "LC_TELEPHONE"
    "LC_TIME"
  ];
in
{
  time.timeZone = cfg.timeZone;

  i18n.defaultLocale = cfg.locale;
  i18n.extraLocaleSettings =
    lib.optionalAttrs (cfg.regionalLocale != null) (
      lib.genAttrs regionalCategories (_: cfg.regionalLocale)
    )
    // cfg.extraLocaleSettings;

  console.keyMap = cfg.consoleKeyMap;

  services.xserver.xkb.layout = cfg.keyboardLayout;
}
