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

    cliphist
    grim
    slop
    solaar
    wl-clipboard
    slurp
  ];
}
