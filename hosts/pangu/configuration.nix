{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  hmRotatingBackup = pkgs.writeShellApplication {
    name = "hm-rotating-backup";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      set -u
      target="''${1:?target path required}"
      keep=3

      rm -f -- "$target.hm-backup.$keep"
      i=$((keep - 1))
      while [ "$i" -ge 1 ]; do
        src="$target.hm-backup.$i"
        dst="$target.hm-backup.$((i + 1))"
        if [ -e "$src" ] || [ -L "$src" ]; then
          mv -f -- "$src" "$dst"
        fi
        i=$((i - 1))
      done

      mv -f -- "$target" "$target.hm-backup.1"
    '';
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ./modules.nix
    ./theme.nix
    ./monitors.nix

    ../../modules/nixos/bundle.nix
  ];

  networking.interfaces.eno1.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };

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

    desktop.gaming.tearing.enable = true;
  };

  home-manager = {
    users.${config.mySystem.user.username} = {
      imports = [ ./home.nix ];
    };

    useGlobalPkgs = true;
    useUserPackages = true;
    backupCommand = lib.getExe hmRotatingBackup;
    extraSpecialArgs = { inherit inputs; };
  };

  system.stateVersion = config.mySystem.system.stateVersion;
}
