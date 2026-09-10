{
  config,
  lib,
  pkgs,
  ...
}:

{
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
}
