{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    vesktop
    (prismlauncher.override {
      jdks = [ jdk8 jdk17 jdk21 ];
      additionalLibs = with pkgs; [
        libGL
        libglvnd
        xorg.libX11
        xorg.libXext
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXxf86vm
      ];
    })
    obsidian
    libreoffice
    mission-center
    vial
    p7zip
    yt-dlp
    wineWowPackages.stable
    winetricks
    spotify
    heroic
    qpwgraph
  ];
}
