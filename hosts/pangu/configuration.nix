{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./monitors.nix
    ./audio.nix

    ../../modules/nixos/bundle.nix
    ../../modules/nixos/desktop/bundle.nix

    ../../modules/nixos/hardware/nvidia.nix
    ../../modules/nixos/hardware/sensors.nix
    ../../modules/nixos/hardware/vial.nix
    ../../modules/nixos/hardware/webcam.nix

    ../../modules/nixos/performance/kernel.nix

    ../../modules/nixos/programs/filemanager.nix
    ../../modules/nixos/programs/gaming.nix
    ../../modules/nixos/programs/lutris.nix

    ../../modules/nixos/services/dlna.nix
    ../../modules/nixos/services/sunshine.nix
  ];

  mySystem = {
    user = {
      username = "jesperls";
      fullName = "Jesper Lönn Stråle";
      email = "jesper.ls@hotmail.com";
    };

    system = {
      hostName = "pangu";
      regionalLocale = "sv_SE.UTF-8";
      autoLogin = true;
      passwordlessSudo = true;
    };

    network.hosts = {
      nuwa = {
        address = "192.168.1.49";
        sshUser = "jesper";
        sshTty = true;
      };
      oracle = {
        address = "132.145.48.11";
        sshUser = "ubuntu";
      };
      gonggong = {
        address = "192.168.1.96";
        sshUser = "jesperls";
        sshTty = true;
      };
    };

    desktop.tearing.enable = true;
    desktop.layouts.centered.fullHeight = true;
    desktop.input.accelProfile = "flat";
    theme.preset = "obsidian-mocha";
    performance.transparentHugepages = "madvise";
    performance.zram.memoryPercent = 25;
    performance.cpuVendor = "amd";
    performance.earlyoom.freeSwapThreshold = 100;

    hardware.nvidia.enable = true;
  };

  boot.kernelModules = [
    "k10temp"
    "nct6775"
  ];

  services.minidlna.settings = {
    friendly_name = "DLNA MEDIA";
    media_dir = [ "V,/srv/media/videos" ];
  };

  services.flatpak.enable = true;
  programs.coolercontrol.enable = true;

  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/70-nuphy.rules" ''
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="19f5", TAG+="uaccess"
    '')
  ];

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 40 * 1024;
    }
  ];

  systemd.tmpfiles.rules = [ "v /swap 0700 root root -" ];
  systemd.services.mkswap-swap-swapfile.preStart = ''
    ${pkgs.systemd}/bin/systemd-tmpfiles --create --prefix=/swap
    ${pkgs.btrfs-progs}/bin/btrfs subvolume show /swap >/dev/null
  '';

  nix.settings = {
    max-jobs = 4;
    cores = 8;
  };

  networking.interfaces.eno1.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };

  home-manager.users.${config.mySystem.user.username}.imports = [ ./home.nix ];

  system.stateVersion = "26.05";
}
