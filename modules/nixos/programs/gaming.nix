{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.programs.gaming;

  shared = import ../lib/gaming.nix { inherit pkgs; };

  # nixpkgs snes9x-gtk 1.63 misses minizip's headers, which moved to
  # include/minizip/.
  snes9x-gtk-fixed = pkgs.snes9x-gtk.overrideAttrs (old: {
    env = (old.env or { }) // {
      NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + " -I${pkgs.minizip}/include/minizip";
    };
  });
in
{
  options.mySystem.programs.gaming.enable =
    lib.mkEnableOption "Steam, gamemode, gamescope and emulators";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];

      gamescopeSession.enable = true;

      package = pkgs.steam.override {
        extraPkgs =
          pkgs:
          with pkgs;
          shared.wineRuntimeLibs
          ++ [
            stdenv.cc.cc.lib
            libkrb5
            keyutils
            vulkan-loader
          ];
      };

      extraPackages = with pkgs; shared.gamingTools;
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
  };
}
