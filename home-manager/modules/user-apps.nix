{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    vesktop
    prismlauncher
    stremio
    obsidian
    libreoffice
  ];
}