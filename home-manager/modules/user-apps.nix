{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    vesktop
    prismlauncher
    stremio
    obsidian
    libreoffice
    mission-center
    vial
    p7zip
    yt-dlp
    wineWowPackages.stable
    winetricks
    spotify
  ];
}
