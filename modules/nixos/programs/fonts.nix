{
  config,
  lib,
  pkgs,
  ...
}:

{
  fonts.fontconfig.enable = true;
  fonts.packages = config.mySystem.theme.fonts.packages;
}
