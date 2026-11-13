{ pkgs, ... }:

{
  home.packages = with pkgs; [
    docker-compose
    fastfetch
    fd
    ripgrep
    jq
    nodejs
    yq
    rsync
    tmux
    unzip
    zip
  ];
}
