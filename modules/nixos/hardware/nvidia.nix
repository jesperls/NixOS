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
    open = true;

    powerManagement.enable = true;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia-container-toolkit.enable = true;

  programs.nix-ld.libraries = [ config.hardware.nvidia.package ];

  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # nvidia-vaapi-driver's default EGL backend is broken on current drivers;
    # without this hardware video decoding silently falls back to software.
    NVD_BACKEND = "direct";
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
