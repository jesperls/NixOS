{
  pkgs,
  ...
}:

{
  programs.steam = {
    enable = true;
    protontricks.enable = true;
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
      gamemode
    ];
  };

  environment.systemPackages = with pkgs; [ mgba ];

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
}
