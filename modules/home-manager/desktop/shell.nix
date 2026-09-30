{
  inputs,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.mySystem.desktop.shell;
in
{
  imports = [ inputs.pangu-shell.homeManagerModules.default ];

  programs.pangu = {
    inherit (cfg) enable wallpapers settings;
    package = pkgs.pangu;
    fonts.enable = false;
    theme.gtk.enable = false;
    theme.qt.enable = false;
  };
}
