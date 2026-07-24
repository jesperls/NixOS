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
    ./programs/fonts.nix
    ./programs/filemanager.nix

    ./desktop/common.nix
    ./desktop/hyprland.nix
    ./desktop/ambxst.nix

    ./performance/optimizations.nix

    ./home-manager.nix
    ./users.nix
  ];
}
