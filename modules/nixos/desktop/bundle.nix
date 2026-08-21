{ ... }:

{
  imports = [
    ./common.nix
    ./hyprland.nix
    ./shell.nix

    ../services/audio.nix
    ../services/bluetooth.nix
    ../programs/fonts.nix
  ];
}
