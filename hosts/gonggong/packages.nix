{ pkgs, ... }:

{
  home.packages = with pkgs; [
    docker-compose
    fastfetch
    fd
    gh
    ripgrep
    jq
    yq
    rsync
    tmux
    unzip
    zip
    opencode
  ];
}

