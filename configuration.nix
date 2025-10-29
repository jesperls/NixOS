{ config, pkgs, userConfig, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # Hardware modules
    ./modules/hardware/nvidia.nix

    # Services modules
    ./modules/services/audio.nix
    ./modules/services/bluetooth.nix

    # Programs modules
    ./modules/programs/gaming.nix
    ./modules/programs/fonts.nix
    ./modules/programs/filemanager.nix

    # Desktop modules
    ./modules/desktop/hyprland.nix

    # Performance modules
    ./modules/performance/optimizations.nix

    # User configuration
    ./modules/users.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = userConfig.hostname;
  networking.networkmanager.enable = true;

  # Time and Locale
  time.timeZone = userConfig.timeZone;
  i18n.defaultLocale = userConfig.locale;
  i18n.extraLocaleSettings = userConfig.extraLocaleSettings;

  console.keyMap = userConfig.consoleKeyMap;
  services.xserver.xkb.layout = userConfig.keyboardLayout;

  hardware.logitech.wireless.enable = true;

  # Enable Nix experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home-manager = {
    users.${userConfig.username} = import ./home-manager/home.nix;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit userConfig; };
  };

  system.stateVersion = "25.05";
}
