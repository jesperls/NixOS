{
  config,
  lib,
  pkgs,
  ...
}:

{
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  hardware.cpu.intel.updateMicrocode = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    priority = 100;
  };

  services.thermald.enable = true;

  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables = {
    "__GL_SHADER_DISK_CACHE" = "1";
    "__GL_SHADER_DISK_CACHE_PATH" = "/tmp/nvidia-shader-cache";
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
    
    "fs.inotify.max_user_watches" = 524288;
    "fs.file-max" = 2097152;
  };

  boot.kernelModules = [ "tcp_bbr" ];

  services.udev.extraRules = ''
    # Set scheduler for NVMe
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    # Set scheduler for SSD
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
  '';

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };
}
