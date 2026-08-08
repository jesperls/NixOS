{ config, lib, ... }:

let
  cfg = config.mySystem.performance;
  mkBase = lib.mkOverride 500; # beats nixpkgs' mkDefault sysctls, loses to a host's plain assignment
in
{
  fileSystems."/".options = lib.mkIf cfg.noatime [ "noatime" ]; # mkIf, not optional: the option is a non-empty list

  zramSwap = lib.mkIf cfg.zram.enable {
    enable = true;
    inherit (cfg.zram) algorithm memoryPercent;
    priority = 100;
  };

  boot.kernel.sysctl = lib.mapAttrs (_: mkBase) {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 268435456; # 256MB
    "vm.dirty_background_bytes" = 134217728; # 128MB
    "vm.max_map_count" = 2147483642;
    "vm.compaction_proactiveness" = 0;

    "net.core.rmem_max" = 33554432;
    "net.core.wmem_max" = 33554432;
    "net.core.netdev_max_backlog" = 16384;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq"; # bbr paces packets itself and needs fq
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_rmem" = "4096 131072 33554432";
    "net.ipv4.tcp_wmem" = "4096 65536 33554432";

    "fs.inotify.max_user_watches" = 1048576;
    "fs.file-max" = 2097152;

    "kernel.split_lock_mitigate" = 0; # 0 only warns, games that trip split locks would otherwise get SIGBUS'd
  };

  services.journald.extraConfig = lib.mkDefault ''
    SystemMaxUse=512M
    SystemMaxFileSize=64M
  '';

  systemd.coredump.settings.Coredump = lib.mapAttrs (_: lib.mkDefault) {
    ProcessSizeMax = "2G";
    ExternalSizeMax = "2G";
    MaxUse = "5G";
  };

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
  '';

  systemd.oomd.enable = lib.mkDefault (!cfg.earlyoom.enable);

  services.earlyoom = lib.mkIf cfg.earlyoom.enable {
    enable = true;
    inherit (cfg.earlyoom) freeMemThreshold freeSwapThreshold;
    enableNotifications = true;
    extraArgs = [
      "--prefer"
      cfg.earlyoom.preferRegex
      "--avoid"
      cfg.earlyoom.avoidRegex
    ];
  };

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  services.fwupd.enable = true;
}
