{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nil
    nixd
    uv
    nodejs
    gcc
    ncdu
    p7zip
    parted
    yt-dlp
    trash-cli
    aria2
    pavucontrol
    qpwgraph
    overskride
    evince
    imv
    evtest
    helix
    lazygit
    nvme-cli
    wget
    libcamera
    v4l-utils
    alsa-utils
    usbutils
    pciutils
  ];
}
