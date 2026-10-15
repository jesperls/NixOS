{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.hardware.nvidia;
in
{
  config = lib.mkIf cfg.enable {
    hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;

      powerManagement.enable = true;

      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    programs.nix-ld.libraries = [ config.hardware.nvidia.package ];

    boot.initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];

    boot.extraModprobeConfig = ''
      options nvidia NVreg_UsePageAttributeTable=1
    '';

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
