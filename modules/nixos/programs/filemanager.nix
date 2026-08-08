{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.programs.fileManager;
in
{
  options.mySystem.programs.fileManager.enable =
    lib.mkEnableOption "Thunar and its desktop integration";

  config = lib.mkIf cfg.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    programs.xfconf.enable = true;

    services.gvfs.enable = true;
    services.tumbler.enable = true;
    services.udisks2.enable = true;
  };
}
