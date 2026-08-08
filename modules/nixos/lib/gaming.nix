{ pkgs }:

{
  wineRuntimeLibs = with pkgs; [
    libGL
    libpng
    libpulseaudio
    libvorbis
    libxkbcommon
    libxcursor
    libxi
    libxinerama
    libxscrnsaver
    wayland
  ];

  gamingTools = with pkgs; [
    mangohud
    gamemode
  ];
}
