{ config, pkgs, zen-browser, ... }:

{
  home.packages = with pkgs; [
    git
    nixfmt-classic
    vscode
    uv
    python314

    vesktop

    obsidian

    firefox
    zen-browser.packages.${pkgs.system}.default

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
