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

    # Audio & Bluetooth
    pavucontrol
    pulseaudio
    bluez-tools
    qpwgraph
    overskride

    # Peripherals
    solaar
    vial

    # Browsing & Communication
    inputs.zen-browser.packages."${system}".default
    vesktop

    # Productivity & Notes
    obsidian
    libreoffice
    gedit

    # File Management & Viewers
    file-roller
    evince
    feh

    # Media & Creative
    mpv
    rhythmbox
    gimp

    # Gaming
    prismlauncher
    heroic

    # Windows Compatibility
    wineWowPackages.stable
    winetricks

    # Entertainment
    spotify
    yt-dlp

    # Customization
    swww
  ];
}
