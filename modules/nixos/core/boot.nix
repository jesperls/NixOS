{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.mySystem.performance;
in
{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
  ];

  hardware.enableRedistributableFirmware = true;

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = config.mySystem.system.keepGenerations;
        editor = false;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    tmp.useTmpfs = true;
    tmp.tmpfsSize = "75%";

    initrd.systemd.enable = lib.mkDefault true;

    kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;

    kernelParams = [
      "quiet"
      "nowatchdog"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ]
    ++ lib.optional (cfg.cpuVendor == "amd") "amd_pstate=active"
    ++ lib.optional (
      cfg.transparentHugepages != null
    ) "transparent_hugepage=${cfg.transparentHugepages}";

    plymouth.enable = false;

    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  specialisation.fallback.configuration = {
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
    services.scx.enable = lib.mkForce false;
    system.nixos.tags = [ "stock-kernel" ];
  };
}
