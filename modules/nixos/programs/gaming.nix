{
  pkgs,
  ...
}:

let
  shared = import ../lib/gaming.nix { inherit pkgs; };
in
{
  boot.kernelModules = [ "ntsync" ];
  boot.kernelParams = [ "split_lock_detect=off" ]; # Avoid kernel traps on unaligned locks in Wine/Proton games.
  boot.kernel.sysctl."kernel.split_lock_mitigate" = 0; # Disables bus_lock_detect throttling on AMD CPUs.

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];

    package = pkgs.steam.override {
      extraLibraries =
        p:
        (import ../lib/gaming.nix { pkgs = p; }).wineRuntimeLibs
        ++ (with p; [
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ]);
    };

    extraPackages = shared.gamingTools;
  };

  environment.systemPackages = with pkgs; [
    lutris
    mangohud
    winetricks

    mgba
    melonds
    ryubing
    snes9x-gtk
    xemu
  ];

  programs.gamemode = {
    enable = true;
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
    enableWsi = true;
    capSysNice = false; # setcap wrapper sets AT_SECURE, stripping LD_PRELOAD for Steam Overlay/MangoHud
  };

  hardware.xpadneo.enable = true;
}
