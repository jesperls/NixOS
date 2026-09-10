{ ... }:

{
  imports = [
    ./environment.nix
    ./theme.nix
    ./xdg.nix
    ./mimeapps.nix
    ./hyprland
    ./kitty.nix
    ./shell.nix
    ./mpv.nix

    ../services/desktop-autostarts.nix
  ];
}
