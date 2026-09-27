{
  lib,
  pkgs,
  ...
}:

let
  shared = import ../lib/gaming.nix { inherit pkgs; };

  # nixpkgs snes9x-gtk 1.63 misses minizip's headers, which moved to
  # include/minizip/.
  snes9x-gtk-fixed = pkgs.snes9x-gtk.overrideAttrs (old: {
    env = (old.env or { }) // {
      NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + " -I${pkgs.minizip}/include/minizip";
    };
  });

  melonds-fixed = pkgs.symlinkJoin {
    name = "melonds-fixed";
    paths = [ pkgs.melonds ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/melonDS --set SDL_JOYSTICK_HIDAPI 0
    '';
  };

  xemu-fixed = pkgs.symlinkJoin {
    name = "xemu-fixed";
    paths = [ pkgs.xemu ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      mv $out/bin/xemu $out/bin/xemu-gapps
      makeWrapper $out/bin/xemu-gapps $out/bin/xemu --set SDL_JOYSTICK_HIDAPI 0
    '';
  };
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
    melonds-fixed
    ryubing
    snes9x-gtk-fixed
    xemu-fixed
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
