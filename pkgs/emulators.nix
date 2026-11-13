{ pkgs }:

{
  melonds = pkgs.symlinkJoin {
    name = "melonds-fixed";
    paths = [ pkgs.melonds ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/melonDS --set SDL_JOYSTICK_HIDAPI 0
    '';
  };

  xemu = pkgs.symlinkJoin {
    name = "xemu-fixed";
    paths = [ pkgs.xemu ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/xemu --set SDL_JOYSTICK_HIDAPI 0
    '';
  };
}
