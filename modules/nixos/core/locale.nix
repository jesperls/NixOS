{ config, lib, pkgs, ... }:

{
  time.timeZone = config.mySystem.system.timeZone;

  i18n.defaultLocale = config.mySystem.system.locale;
  i18n.extraLocaleSettings = config.mySystem.system.extraLocaleSettings;

  console.keyMap = config.mySystem.system.consoleKeyMap;

  services.xserver.xkb.layout = config.mySystem.system.keyboardLayout;
}
