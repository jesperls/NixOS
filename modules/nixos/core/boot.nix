{ pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        editor = false;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    kernelParams = [
      "quiet"
      "splash"
      "nowatchdog"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "video=DP-3:2560x1440@240"
      "video=DP-2:2560x1440@144"
      "video=HDMI-A-1:1920x1080@60"
    ];

    plymouth.enable = false;

    consoleLogLevel = 0;
    initrd.verbose = false;

    tmp = {
      useTmpfs = true;
      tmpfsSize = "8G";
    };
  };
}
