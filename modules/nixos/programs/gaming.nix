{
  lib,
  pkgs,
  ...
}:

let
  shared = import ../lib/gaming.nix { inherit pkgs; };
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
    melonds
    ryubing
    snes9x-gtk
    xemu
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
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("com.feralinteractive.GameMode.") === 0 &&
          subject.isInGroup("gamemode")) {
        return polkit.Result.YES;
      }
    });
  '';

  hardware.xpadneo.enable = true;
}
