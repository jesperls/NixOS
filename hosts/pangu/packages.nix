{
  pkgs,
  inputs,
  ...
}:

let
  discord-krisp = (import inputs.nixpkgs-discord-krisp {
    system = pkgs.stdenv.system;
    config.allowUnfree = true;
  }).discord;
in

{
  home.packages = with pkgs; [
    nixfmt-tree
    nixfmt
    nil
    vscode
    uv
    python314
    nodejs
    ydotool
    jq
    yq
    fd
    ripgrep
    htop
    ncdu
    p7zip
    parted
    yt-dlp
    playerctl
    trash-cli
    aria2
    grim
    slurp
    swappy
    libnotify
    gpu-screen-recorder-gtk
    wl-clipboard
    cliphist
    wofi
    gsettings-desktop-schemas
    wlogout
    networkmanagerapplet
    mission-center
    pavucontrol
    qpwgraph
    overskride
    audacity
    solaar
    scrcpy
    obsidian
    gedit
    gimp
    prismlauncher
    qbittorrent
    (discord-krisp.override {
      withVencord = true;
      withOpenASAR = true;
      withKrisp = true;
    })
    file-roller
    unzip
    zip
    unrar
    evince
    imv
    faugus-launcher
    umu-launcher
    protonup-qt
    evtest
    burpsuite
  ];
}
