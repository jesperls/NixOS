{ pkgs, inputs, ... }:

let
  cachyKernel = pkgs.cachyosKernels.linux-cachyos-latest.override {
    cpusched = "eevdf";
    lto = "thin";
    processorOpt = "zen4";
    bbr3 = true;
    autofdo = true;
  };

  helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };
in
{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    # Skipping tests while upstream sorts it out, revert once
    # Hydra consistently builds openldap green.
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

    kernelPackages = helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor cachyKernel);
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
