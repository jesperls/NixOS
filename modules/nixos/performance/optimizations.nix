{ ... }:

{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 268435456; # 256MB
    "vm.dirty_background_bytes" = 134217728; # 128MB
    "vm.max_map_count" = 2147483642;

    "net.core.rmem_max" = 33554432;
    "net.core.wmem_max" = 33554432;
    "net.core.netdev_max_backlog" = 16384;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_rmem" = "4096 131072 33554432";
    "net.ipv4.tcp_wmem" = "4096 65536 33554432";

    "fs.inotify.max_user_watches" = 1048576;
    "fs.file-max" = 2097152;

    "kernel.nmi_watchdog" = 0;
  };

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # uinput access for Sunshine
    KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
  '';

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 5;
    enableNotifications = true;
    extraArgs = [
      "--prefer"
      "(^|/)(wine|wineserver|Battle\\.net|lutris-wrapper)$|^/.*/(drive_c|Program Files|steamapps)/.*\\.exe$"
      "--avoid"
      # quickshell matched unanchored: its comm name truncates to ".quickshell-wra"
      "(^|/)(Hyprland|pipewire|wireplumber)$|quickshell|caelestia"
    ];
  };

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  services.fwupd.enable = true;
}
