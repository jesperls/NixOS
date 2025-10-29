{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Core Development Tools
    git
    nixfmt-classic
    vscode
    uv
    python314

    # System Utilities & Tools
    cliphist
    grim
    slop
    wl-clipboard
    slurp
    jq
    desync
    nh
    xdg-utils
    solaar
    htop
    
    # Audio & Bluetooth
    pavucontrol
    bluez-tools
    overskride

    # Essential Applications
    firefox
    gedit
    wlogout
    nm-tray
    networkmanagerapplet

    # File Management & Viewers
    feh
    evince
    file-roller

    # Media Applications
    mpv
    rhythmbox
  ];
}
