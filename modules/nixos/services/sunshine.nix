{ config, lib, ... }:

let
  cfg = config.mySystem.services.sunshine;
in
{
  options.mySystem.services.sunshine = {
    enable = lib.mkEnableOption "Sunshine game streaming server";
  };

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
