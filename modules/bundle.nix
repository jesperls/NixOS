{ ... }:

{
  imports = [
    ./core/boot.nix
    ./core/network.nix
    ./core/nix.nix
    ./core/options.nix

    ./hardware/nvidia.nix
    ./hardware/vial.nix

    ./services/audio.nix
    ./services/bluetooth.nix
    ./services/backup.nix

    ./programs/gaming.nix
    ./programs/fonts.nix
    ./programs/filemanager.nix

    ./desktop/hyprland.nix

    ./performance/optimizations.nix

    ./users.nix
  ];
}
