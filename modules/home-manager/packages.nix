{ config, pkgs, ... }:

{
  # User package installation
  # Organized by category for easy maintenance

  home.packages = with pkgs; [
    # Development Tools
    git
    nixfmt-classic
    vscode
    uv
    python314
    antigravity
    nodejs
    dbeaver-bin

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
    glib
    gsettings-desktop-schemas
    p7zip

    # CUDA
    cudaPackages.cudnn

    # Audio & Bluetooth
    pavucontrol
    bluez-tools
    overskride
    qpwgraph

    # Desktop Applications
    gedit
    wlogout
    networkmanagerapplet
    firefox
    vesktop
    obsidian
    mission-center
    vial

    # File Management & Viewers
    feh
    evince
    file-roller

    # Media & Creative
    mpv
    rhythmbox
    gimp

    # Gaming
    prismlauncher
    heroic

    # Office & Productivity
    libreoffice

    # Windows Compatibility
    wineWowPackages.stable
    winetricks

    # Entertainment
    spotify
    yt-dlp
  ];
}
