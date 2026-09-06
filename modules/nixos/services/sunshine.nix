{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.services.sunshine;
in
{
  options.mySystem.services.sunshine.enable = lib.mkEnableOption "the Sunshine game-streaming host";

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      package = lib.mkDefault (
        pkgs.sunshine.override {
          cudaSupport = config.mySystem.hardware.nvidia.enable;
        }
      );
    };

  };
}
