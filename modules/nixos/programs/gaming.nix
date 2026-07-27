{
  pkgs,
  ...
}:

let
  # nixpkgs snes9x-gtk 1.63 misses minizip's headers, which moved to
  # include/minizip/.
  snes9x-gtk-fixed = pkgs.snes9x-gtk.overrideAttrs (old: {
    env = (old.env or { }) // {
      NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + " -I${pkgs.minizip}/include/minizip";
    };
  });
in
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

  environment.systemPackages = with pkgs; [
    mgba
    ryubing
    snes9x-gtk-fixed
  ];

  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
        ioprio = 0;
        inhibit_screensaver = 1;
      };
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  hardware.xpadneo.enable = true;
}
