{ pkgs, ... }:

{
  home.packages = with pkgs; [
    docker-compose
    fastfetch
    fd
    gh
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
