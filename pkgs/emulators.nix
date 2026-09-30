{ pkgs }:

{
  snes9x-gtk = pkgs.snes9x-gtk.overrideAttrs (old: {
    env = (old.env or { }) // {
      NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + " -I${pkgs.minizip}/include/minizip"; # minizip moved its headers into a subdirectory.
    };
  });

  melonds = pkgs.symlinkJoin {
    name = "melonds-fixed";
    paths = [ pkgs.melonds ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/melonDS --set SDL_JOYSTICK_HIDAPI 0
    '';
  };

  xemu = pkgs.symlinkJoin {
    name = "xemu-fixed";
    paths = [ pkgs.xemu ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      mv $out/bin/xemu $out/bin/xemu-gapps
      makeWrapper $out/bin/xemu-gapps $out/bin/xemu --set SDL_JOYSTICK_HIDAPI 0
    '';
  };
}
