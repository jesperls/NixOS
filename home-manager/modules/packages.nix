{ config, pkgs, antigravity-nix, ... }:

{
  home.packages = with pkgs; [
    # Core Development Tools
    git
    nixfmt-classic
    vscode
    uv
    python314
    antigravity-nix.packages.x86_64-linux.default

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
    ncdu
    nodejs
    glib
    gsettings-desktop-schemas

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
