{
  config,
  pkgs,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    powerManagement.enable = true;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  boot.kernelParams = [
    "nvidia-drm.fbdev=1"
  ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
