{
  pkgs,
  ...
}:

let
  shared = import ../lib/gaming.nix { inherit pkgs; };
in
{
  boot.kernelParams = [ "split_lock_detect=off" ]; # Avoid kernel traps on unaligned locks in Wine/Proton games.

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
    enableRenice = false; # ananicy-cpp manages process nice levels.
    settings = {
      general = {
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
