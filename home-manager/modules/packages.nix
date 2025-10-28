{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    nixfmt-classic
    vscode
    uv
    python314

    vesktop
    prismlauncher

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
    jq
    desync

    nh
  ];
}
