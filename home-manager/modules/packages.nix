{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    nixfmt
    vscode
    uv
    python314

    vesktop

    obsidian

    firefox

    feh
    evince
    file-roller
    
    mpv
    rhythmbox
    
    gedit
    
    libreoffice
    
    cliphist
    grim
    slop
    solaar
    wl-clipboard
    slurp
  ];
}
