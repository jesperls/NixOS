{
  config,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
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
      keyboardLayout = "se";
      consoleKeyMap = "sv-latin1";
      stateVersion = "26.05";
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

    hardware.nvidia.enable = true;
    hardware.vial.enable = true;
    hardware.webcam.enable = true;
    hardware.fancontrol.enable = true;
    hardware.logitech.enable = true;

    services.backup.enable = true;
    services.bluetooth.enable = true;
    services.flatpak.enable = true;
    services.audio.enable = true;
    services.sunshine.enable = true;

    programs.gaming.enable = true;
    programs.lutris.enable = true;
    programs.fonts.enable = true;
    programs.filemanager.enable = true;

    performance.enable = true;
  };

  services.speechd.enable = true;

  home-manager = {
    users.${config.mySystem.user.username} = {
      imports = [ ./home.nix ];
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
  };

  system.stateVersion = config.mySystem.system.stateVersion;
}
