{ pkgs, ... }:

{
  home.packages = with pkgs; [
    antigravity-cli
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
