{ config, lib, pkgs, ... }:

with lib;

let cfg = config.mySystem.services.flatpak;
in {
  options.mySystem.services.flatpak = {
    enable = mkEnableOption "Flatpak package manager";
  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;

    xdg.portal.enable = true;
  };
}
