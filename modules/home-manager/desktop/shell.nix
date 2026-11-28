{
  inputs,
  osConfig,
  ...
}:

let
  cfg = osConfig.mySystem.desktop.shell;
in
{
  imports = [ inputs.pangu-shell.homeModules.default ];

  programs.pangu = {
    inherit (cfg) enable wallpapers settings;
    fonts.enable = false;
    theme = {
      kitty.enable = true;
      firefox.enable = true;
      spicetify.enable = false;
    };
  };
}
