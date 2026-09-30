{ lib, ... }:

{
  options.mySystem.performance = {
    cpuVendor = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "amd"
          "intel"
        ]
      );
      default = null;
      description = "Which vendor's pstate driver to request on the kernel command line; null keeps the kernel default.";
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
      description = "sched_ext scheduler to load on a supporting kernel; null keeps EEVDF.";
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

    zram = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Compressed RAM swap.";
      };
      memoryPercent = lib.mkOption {
        type = lib.types.ints.between 1 200;
        default = 50;
        description = "Ceiling on lazily allocated zram as a percentage of RAM.";
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
        description = "Use earlyoom instead of systemd-oomd to act on free memory and swap.";
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
