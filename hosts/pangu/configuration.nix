{ config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules.nix
    ./theme.nix
    ./monitors.nix

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

    desktop.idle.enable = false;
    desktop.gaming.tearing.enable = true;
    desktop.layouts.centered.fullHeight = true;

    services.dlna = {
      enable = true;
      friendlyName = "DLNA MEDIA";
      mediaDirs = [ "V,/srv/media/videos" ];
    };
  };

  networking.interfaces.eno1.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };

  home-manager.users.${config.mySystem.user.username}.imports = [ ./home.nix ];

  system.stateVersion = config.mySystem.system.stateVersion;
}
