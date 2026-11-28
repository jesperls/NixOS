{ pkgs, ... }:

{
  home.packages = with pkgs; [
    antigravity-cli
    docker-compose
    jq
    nodejs
    rsync
    tmux
  ];
}
