{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];

  hardware.enableRedistributableFirmware = true;

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

    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;
    kernelParams = [
      "quiet"
      "splash"
      "nowatchdog"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "amd_pstate=active"
    ];

    plymouth.enable = false;

    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
