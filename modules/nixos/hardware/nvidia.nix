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
  options.mySystem.hardware.nvidia.enable = lib.mkEnableOption "the NVIDIA driver stack";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
      ];
    };

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
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
