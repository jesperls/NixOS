{ config, pkgs, inputs, lib, ... }:

let system = pkgs.stdenv.hostPlatform.system;
in {
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
    inputs.deltatune.packages.${system}.default

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
    inputs.zen-browser.packages.${system}.twilight
    vesktop
    obsidian
    libreoffice
    gedit
    mpv
    rhythmbox
    gimp
    prismlauncher
    heroic
    qbittorrent

    # File Management & Viewers
    file-roller
    unzip
    zip
    unrar
    evince
    feh
    adwaita-icon-theme

    # Windows Compatibility
    wineWowPackages.stable
    winetricks
  ];
}
