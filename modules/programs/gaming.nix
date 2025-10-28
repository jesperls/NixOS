{ config, lib, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];

    gamescopeSession.enable = false;

    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
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

    extraPackages = with pkgs; [ mangohud ];
  };

  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = { general = { renice = 10; }; };
  };

  environment.systemPackages = with pkgs; [ mangohud gamemode ];
}
