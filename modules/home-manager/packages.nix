{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Development
    git
    nixfmt-classic
    vscode
    uv
    python314
    nodejs
    dbeaver-bin
    cudaPackages.cudnn

    # CLI & System Utilities
    nh
    jq
    xdg-utils
    htop
    ncdu
    p7zip
    parted
    desync
    yt-dlp

    # Wayland & Desktop Tools
    grim
    slurp
    slop
    wl-clipboard
    cliphist
    gsettings-desktop-schemas
    glib
    wlogout
    networkmanagerapplet
    mission-center
    swww

    # Audio & Bluetooth
    pavucontrol
    pulseaudio
    bluez-tools
    qpwgraph
    overskride

    # Peripherals
    solaar
    vial

    # Apps
    inputs.zen-browser.packages."${system}".default
    vesktop
    obsidian
    libreoffice
    gedit
    mpv
    rhythmbox
    gimp
    prismlauncher
    heroic

    # File Management & Viewers
    file-roller
    evince
    feh

    # Windows Compatibility
    wineWowPackages.stable
    winetricks
  ];
}
