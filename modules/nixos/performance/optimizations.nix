{ config, lib, ... }:

let
  cfg = config.mySystem.performance;
  mkBase = lib.mkOverride 500; # beats nixpkgs' mkDefault sysctls, loses to a host's plain assignment
in
{
  fileSystems."/".options = lib.mkIf cfg.noatime.enable [ "noatime" ]; # mkIf, not optional: the option is a non-empty list

  zramSwap = lib.mkIf cfg.zram.enable {
    enable = true;
    inherit (cfg.zram) algorithm memoryPercent;
    priority = 100;
  };

  boot.kernel.sysctl = lib.mapAttrs (_: mkBase) {
    "vm.swappiness" = if cfg.zram.enable then 180 else 60;
    "vm.page-cluster" = 0;
    "vm.dirty_bytes" = 268435456; # 256MB
    "vm.dirty_background_bytes" = 134217728; # 128MB
    "vm.max_map_count" = 2147483642;

    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";

    "fs.inotify.max_user_watches" = 1048576;
  };

  services.journald.settings.Journal = lib.mapAttrs (_: lib.mkDefault) {
    SystemMaxUse = "512M";
    SystemMaxFileSize = "64M";
  };

  systemd.coredump.settings.Coredump = lib.mapAttrs (_: lib.mkDefault) {
    ProcessSizeMax = "2G";
    ExternalSizeMax = "2G";
    MaxUse = "5G";
  };

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
