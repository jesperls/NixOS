{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ../../modules/nixos/bundle.nix ];

  mySystem = {
    user = {
      username = "jesperls";
      fullName = "Jesper Lönn Stråle";
      email = "jesperls@example.com";
    };
    system = {
      hostName = "nixos";
      timeZone = "Europe/Stockholm";
      locale = "en_US.UTF-8";
      keyboardLayout = "se";
      consoleKeyMap = "sv-latin1";
      stateVersion = "25.05";
      extraLocaleSettings = {
        LC_ADDRESS = "sv_SE.UTF-8";
        LC_IDENTIFICATION = "sv_SE.UTF-8";
        LC_MEASUREMENT = "sv_SE.UTF-8";
        LC_MONETARY = "sv_SE.UTF-8";
        LC_NAME = "sv_SE.UTF-8";
        LC_NUMERIC = "sv_SE.UTF-8";
        LC_PAPER = "sv_SE.UTF-8";
        LC_TELEPHONE = "sv_SE.UTF-8";
        LC_TIME = "sv_SE.UTF-8";
      };
    };

    # Monitor configuration
    monitors = [
      "DP-3, 2560x1440@240, 0x0, 1"
      "DP-2, 2560x1440@144, 2560x0, 1"
      "HDMI-A-1, 1920x1080@60, -1080x0, 1, transform, 1"
      ", preferred, auto, 1"
      "Unknown-1, disable"
    ];

    # Hardware features
    hardware.nvidia.enable = true;
    hardware.vial.enable = true;

    # Services
    services.backup.enable = true;
    services.bluetooth.enable = true;
    services.flatpak.enable = true;
    services.audio = {
      enable = true;
      hybrid = {
        enable = true;
        preferredNode = "alsa_input.usb-Logitech_A50-00.pro-input-0";
        fallbackNode =
          "alsa_input.usb-Focusrite_Scarlett_2i2_4th_Gen_S20KXTT350BDD8-00.pro-input-0";
        sinkName = "hybrid_voice_input";
      };
    };

    # Programs
    programs.gaming.enable = true;
  };

  # Home Manager configuration
  home-manager = {
    users.${config.mySystem.user.username} = { imports = [ ./home.nix ]; };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
  };

  system.stateVersion = config.mySystem.system.stateVersion;
}
