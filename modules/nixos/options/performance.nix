{ config, lib, ... }:

{
  options.mySystem.performance = {
    cpuVendor = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "amd"
          "intel"
        ]
      );
      default =
        if config.hardware.cpu.amd.updateMicrocode then
          "amd"
        else if config.hardware.cpu.intel.updateMicrocode then
          "intel"
        else
          null;
      defaultText = lib.literalMD "detected from `hardware-configuration.nix`";
      description = "Which vendor's pstate driver to request on the kernel command line.";
    };

    scheduler = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "scx_lavd"
          "scx_bpfland"
          "scx_flash"
          "scx_p2dq"
          "scx_rusty"
          "scx_cosmos"
        ]
      );
      default = null;
      example = "scx_lavd";
      description = ''
        sched_ext scheduler to load instead of EEVDF; needs a kernel with
        CONFIG_SCHED_CLASS_EXT. scx_lavd is latency-first, scx_rusty is
        topology-aware. null keeps EEVDF.
      '';
    };

    transparentHugepages = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "always"
          "madvise"
          "never"
        ]
      );
      default = null;
      description = "transparent_hugepage= kernel parameter; null keeps the kernel default.";
    };

    kernel = {
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

    ananicy = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto-nice daemon with the CachyOS rule set, so background jobs cannot starve the compositor.";
    };

    irqbalance = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Spread hardware interrupts across cores instead of leaving them on CPU0.";
    };

    noatime = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Mount the root filesystem noatime.";
    };

    zram = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Compressed RAM swap.";
      };
      memoryPercent = lib.mkOption {
        type = lib.types.ints.between 1 200;
        default = 50;
        description = "Ceiling on zram size as a percentage of RAM. Lazily allocated.";
      };
      algorithm = lib.mkOption {
        type = lib.types.str;
        default = "zstd";
        description = "Compression algorithm.";
      };
    };

    earlyoom = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Userspace OOM killer. Disables systemd-oomd, which kills on cgroup pressure instead of free memory.";
      };
      freeMemThreshold = lib.mkOption {
        type = lib.types.ints.between 1 100;
        default = 5;
        description = "Percentage of free RAM below which earlyoom starts killing.";
      };
      freeSwapThreshold = lib.mkOption {
        type = lib.types.ints.between 1 100;
        default = 5;
        description = "Percentage of free swap below which earlyoom starts killing.";
      };
      preferRegex = lib.mkOption {
        type = lib.types.str;
        default = "(^|/)(wine|wineserver|Battle\\.net|lutris-wrapper)$|^/.*/(drive_c|Program Files|steamapps)/.*\\.exe$";
        description = "Processes to kill first.";
      };
      avoidRegex = lib.mkOption {
        type = lib.types.str;
        default = "(^|/)(Hyprland|pipewire|wireplumber|qs|\\.qs-wrapped)$|quickshell|pangu";
        description = "Processes to kill last.";
      };
    };
  };
}
