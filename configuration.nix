{ config, pkgs, lib, swww, antigravity-nix, ... }:

{
  imports = [ ./hardware-configuration.nix ./modules/bundle.nix ];

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
    monitors = [
      "DP-3, 2560x1440@240, 0x0, 1"
      "DP-2, 2560x1440@144, 2560x0, 1"
      "HDMI-A-1, 1920x1080@60, -1080x0, 1, transform, 1"
      ", preferred, auto, 1"
      "Unknown-1, disable"
    ];

    services.backup.enable = true;
    hardware.nvidia.enable = true;
    programs.gaming.enable = true;
  };

  time.timeZone = config.mySystem.system.timeZone;
  i18n.defaultLocale = config.mySystem.system.locale;
  i18n.extraLocaleSettings = config.mySystem.system.extraLocaleSettings;

  console.keyMap = config.mySystem.system.consoleKeyMap;
  services.xserver.xkb.layout = config.mySystem.system.keyboardLayout;

  hardware.logitech.wireless.enable = true;

  home-manager = {
    users.${config.mySystem.user.username} = import ./home-manager/home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit swww antigravity-nix; };
  };

  system.stateVersion = "25.05";
}
