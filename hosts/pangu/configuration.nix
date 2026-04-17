{
  config,
  inputs,
  lib,
  ...
}:

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
      keyboardLayout = "se";
      consoleKeyMap = "sv-latin1";
      stateVersion = "26.05";
      extraLocaleSettings = lib.genAttrs [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MONETARY"
        "LC_NAME"
        "LC_NUMERIC"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
      ] (_: "sv_SE.UTF-8");
    };

    home.stateVersion = "26.05";
  };

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
