{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # Hardware modules
    ./modules/hardware/nvidia.nix

    # Services modules
    ./modules/services/audio.nix

    # Programs modules
    ./modules/programs/gaming.nix
    ./modules/programs/fonts.nix
    ./modules/programs/filemanager.nix

    # Desktop modules
    ./modules/desktop/hyprland.nix

    # User configuration
    ./modules/users.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time and Locale
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

  console.keyMap = "sv-latin1";
  services.xserver.xkb.layout = "se";

  hardware.logitech.wireless.enable = true;

  home-manager = {
    users.jesperls = import ./home-manager/home.nix;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  systemd.tmpfiles.settings."10-nixos-directory"."/etc/nixos".d = {
    group = "nix";
    mode = "0755";
  };

  system.stateVersion = "25.05";
}
