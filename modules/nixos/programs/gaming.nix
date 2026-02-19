{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.programs.gaming;
in
{
  options.mySystem.programs.gaming = {
    enable = lib.mkEnableOption "Gaming configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];

      gamescopeSession.enable = true;

      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            libxcursor
            libxi
            libxinerama
            libxscrnsaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
            wayland
            libxkbcommon
            vulkan-loader
            vulkan-validation-layers
          ];
      };

      extraPackages = with pkgs; [
        mangohud
      ];
    };

    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
        };
      };
    };

    programs.gamescope = {
      enable = true;
      capSysNice = false;
    };

  };
}
