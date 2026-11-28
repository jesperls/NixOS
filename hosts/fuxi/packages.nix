{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nixd
    uv
    nodejs
    gcc
    ncdu
    _7zz
    parted
    yt-dlp
    trash-cli
    aria2
    pwvucontrol
    qpwgraph
    overskride
    papers
    imv
    evtest
    helix
    lazygit
    herdr-desktop
    nvme-cli
    wget
    libcamera
    v4l-utils
    alsa-utils
    usbutils
    pciutils
  ];
}
