{ config, lib, pkgs, ... }:

with lib;

let cfg = config.mySystem.hardware.nvidia;
in {
  options.mySystem.hardware.nvidia = {
    enable = mkEnableOption "Nvidia drivers";
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.nvidia = {
      modesetting.enable = true;
      open = false;

      powerManagement.enable = true;
      powerManagement.finegrained = false;

      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    boot.kernelParams = [ "nvidia-drm.modeset=1" ];

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      NIXOS_OZONE_WL = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
    };

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
