{ ... }:

{
  imports = [
    ./theme.nix
    ./xdg.nix
    ./mimeapps.nix
    ./hyprland
    ./shell.nix
    ./mpv.nix

    ../services/desktop-autostarts.nix
  ];
}
