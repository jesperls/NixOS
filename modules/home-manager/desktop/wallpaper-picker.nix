{
  inputs,
  osConfig,
  ...
}:
{
  imports = [ inputs.wallpaper-picker.homeManagerModules.default ];

  programs.wallpaperPicker = {
    enable = true;
    baseColors = osConfig.mySystem.theme.colors;
    baseRounding = osConfig.mySystem.theme.rounding;
  };
}
