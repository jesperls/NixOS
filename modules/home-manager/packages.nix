{
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  # Environment variables to help uv work properly on NixOS
  home.sessionVariables = {
    # Tell uv to use the system Python as a fallback and help with linking
    UV_PYTHON_PREFERENCE = "managed";
    # Ensure pip/uv can find SSL certificates
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    # Help compiled extensions find libraries
    LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:/run/current-system/sw/lib";
  };

  home.packages = with pkgs; [
    nixfmt
    nil
    vscode
    uv
    python314
    nodejs
    dbeaver-bin
    git
    ydotool

    # === CLI Utilities ===
    nh
    jq
    yq
    fd
    ripgrep
    xdg-utils
    htop
    ncdu
    p7zip
    parted
    yt-dlp
    playerctl
    trash-cli
    
    # === Screen/Display ===
    grim
    slurp
    wl-clipboard
    cliphist
    wofi

    # === System Integration ===
    gsettings-desktop-schemas
    glib
    wlogout
    networkmanagerapplet
    mission-center

    # === Audio ===
    pavucontrol
    pulseaudio
    qpwgraph
    overskride
    easyeffects
    espeak

    # === Hardware ===
    solaar
    scrcpy

    # === Applications ===
    inputs.zen-browser.packages.${system}.beta
    obsidian
    libreoffice
    gedit
    mpv
    rhythmbox
    gimp
    prismlauncher
    heroic
    qbittorrent

    # === File Management ===
    file-roller
    unzip
    zip
    unrar
    evince
    feh
    imv

    # === Theming ===
    adwaita-icon-theme

    # === Gaming/Wine ===
    wineWowPackages.stable
    winetricks

    # === CUDA ===
    cudaPackages.cudnn

    # === Custom Packages ===
    inputs.deltatune.packages.${system}.default
  ];
}
