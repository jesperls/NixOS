{ ... }:

{
  imports = [
    ./options

    ./core/boot.nix
    ./core/network.nix
    ./core/nix.nix
    ./core/locale.nix

    ./services/audio.nix
    ./services/bluetooth.nix
    ./services/flatpak.nix
    ./services/dlna.nix
    ./services/home-assistant.nix
    ./programs/fonts.nix
    ./programs/filemanager.nix

    ./desktop/common.nix
    ./desktop/hyprland.nix
    ./desktop/shell.nix

    ./performance/optimizations.nix
    ./performance/scheduling.nix

    ./home-manager.nix
    ./users.nix
  ];
}
