{ config, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./theme.nix
    ./monitors.nix
    ./audio.nix

    ../../modules/nixos/bundle.nix
  ];

  mySystem = {
    user = {
      username = "jesperls";
      fullName = "Jesper Lönn Stråle";
      email = "jesper.ls@hotmail.com";
    };

    system = {
      hostName = "pangu";
      timeZone = "Europe/Stockholm";
      locale = "en_US.UTF-8";
      regionalLocale = "sv_SE.UTF-8";
      keyboardLayout = "se";
      consoleKeyMap = "sv-latin1";
      stateVersion = "26.05";
      autoLogin = true;
      passwordlessSudo = true;
    };

    home.stateVersion = "26.05";

    network.hosts = {
      nuwa = "192.168.1.49";
      oracle = "132.145.48.11";
    };

    desktop.gaming.tearing.enable = true;
    desktop.layouts.centered.fullHeight = true;
    desktop.input.accelProfile = "flat";
    performance.scheduler = "scx_lavd";
    performance.transparentHugepages = "always";
    performance.zram.memoryPercent = 25;
    performance.cpuVendor = "amd";
    # Tuned kernel — re-enable once you have a merged profile (docs/autofdo.md):
    #   performance.kernel = {
    #     processorOpt = "zen4";
    #     autofdo = ./profiles/merged.afdo;
    #     performanceGovernor = true;
    #     bbr3 = true;
    #   };
    performance.autofdo = {
      enable = true;
      minCpuLoad = 0.1;
    };

    hardware.nvidia.enable = true;
    hardware.vial.enable = true;
    hardware.webcam.enable = true;
    hardware.sensors = {
      enable = true;
      modules = [
        "k10temp"
        "nct6775"
      ];
    };

    programs.coolercontrol = {
      enable = true;
    };

    programs.gaming.enable = true;
    programs.lutris.enable = true;
    programs.fileManager.enable = true;

    services.flatpak.enable = true;
    services.sunshine.enable = true;
    services.ollama.enable = false;

    services.homeAssistant = {
      enable = false;
      privileged = true;
      mqtt = {
        enable = true;
        server = "tcp://${config.mySystem.network.hosts.nuwa}:1883";
      };
    };

    services.dlna = {
      enable = true;
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
