{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.mySystem.performance;

  # x86_64-v1 is the flake default; untouched options keep hitting the pinned binary cache
  kernelOpts = {
    processorOpt = if cfg.kernel.processorOpt == null then "x86_64-v1" else cfg.kernel.processorOpt;
    autofdo = cfg.kernel.autofdo;
    performanceGovernor = cfg.kernel.performanceGovernor;
    bbr3 = cfg.kernel.bbr3;
  };

  defaultOpts = {
    processorOpt = "x86_64-v1";
    autofdo = false;
    performanceGovernor = false;
    bbr3 = false;
  };

  customKernel = pkgs.cachyosKernels.linux-cachyos-latest-lto.override kernelOpts;

  kernelPackages =
    if kernelOpts == defaultOpts then
      pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto
    else
      (pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { }).kernelModuleLLVMOverride (
        pkgs.linuxKernel.packagesFor customKernel
      );
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

    kernelPackages = lib.mkDefault kernelPackages;

    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ]
    ++ lib.optional (cfg.cpuVendor == "amd") "amd_pstate=active"
    ++ lib.optional (
      cfg.transparentHugepages != null
    ) "transparent_hugepage=${cfg.transparentHugepages}";

    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  specialisation.fallback.configuration = {
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
    services.scx.enable = lib.mkForce false;
    system.nixos.tags = [ "stock-kernel" ];
  };
}
