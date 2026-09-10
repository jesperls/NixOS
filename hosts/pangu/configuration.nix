{ config, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./theme.nix
    ./monitors.nix
    ./audio.nix

    ../../modules/nixos/bundle.nix
    ../../modules/nixos/desktop/bundle.nix

    ../../modules/nixos/hardware/nvidia.nix
    ../../modules/nixos/hardware/sensors.nix
    ../../modules/nixos/hardware/vial.nix
    ../../modules/nixos/hardware/webcam.nix

    ../../modules/nixos/performance/autofdo.nix
    ../../modules/nixos/performance/kernel.nix

    ../../modules/nixos/programs/coolercontrol.nix
    ../../modules/nixos/programs/filemanager.nix
    ../../modules/nixos/programs/gaming.nix
    ../../modules/nixos/programs/lutris.nix

    ../../modules/nixos/services/dlna.nix
    ../../modules/nixos/services/flatpak.nix
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
    performance.transparentHugepages = "madvise";
    performance.zram.memoryPercent = 25;
    performance.cpuVendor = "amd";
    # Tuned kernel — re-enable once you have a merged profile (docs/autofdo.md):
    #   performance.kernel = {
    #     processorOpt = "zen4";
    #     autofdo = ./profiles/merged.afdo;
    #     performanceGovernor = true;
    #     bbr3 = true;
    #   };
    performance.autofdo.minCpuLoad = 0.1;

    hardware.nvidia.enable = true;
    hardware.sensors.modules = [
      "k10temp"
      "nct6775"
    ];

    services.dlna = {
      friendlyName = "DLNA MEDIA";
      mediaDirs = [ "V,/srv/media/videos" ];
    };
  };

  nix.settings = {
    max-jobs = 4;
    cores = 8;
  };

  nixpkgs.config.allowInsecurePredicate = p: lib.getName p == "electron";

  networking.interfaces.eno1.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };

  home-manager.users.${config.mySystem.user.username}.imports = [ ./home.nix ];

  system.stateVersion = config.mySystem.system.stateVersion;
}
