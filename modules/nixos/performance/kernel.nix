{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.mySystem.performance.kernel;

  kernelOpts = {
    processorOpt = if cfg.processorOpt == null then "x86_64-v1" else cfg.processorOpt;
    autofdo = cfg.autofdo;
    performanceGovernor = cfg.performanceGovernor;
    bbr3 = cfg.bbr3;
  };

  defaultOpts = {
    processorOpt = "x86_64-v1";
    autofdo = false;
    performanceGovernor = false;
    bbr3 = false;
  };

  # x86_64-v1 is the flake default; untouched options keep hitting the pinned
  # binary cache, anything else forces a local build.
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
  options.mySystem.performance.kernel = {
    processorOpt = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "x86_64-v2"
          "x86_64-v3"
          "x86_64-v4"
          "zen4"
        ]
      );
      default = null;
      description = "Microarchitecture the CachyOS kernel is compiled for; zen4 also covers Zen 5.";
    };

    autofdo = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.bool lib.types.path);
      default = false;
      description = "Clang AutoFDO: true enables the profiling config, a profile path applies it.";
    };

    performanceGovernor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Pin the default cpufreq governor to performance.";
    };

    bbr3 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Build BBRv3 and make it the default TCP congestion control.";
    };
  };

  config = {
    nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

    boot.kernelPackages = lib.mkDefault kernelPackages;

    specialisation.fallback.configuration = {
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
      services.scx.enable = lib.mkForce false;
      system.nixos.tags = [ "stock-kernel" ];
    };
  };
}
