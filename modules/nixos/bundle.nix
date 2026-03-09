{ ... }:

{
  imports = [
    # Shared configuration that should apply to all desktop hosts.
    ./core/boot.nix
    ./core/network.nix
    ./core/nix.nix
    ./core/options.nix
    ./core/locale.nix
    ./core/theme-options.nix

    ./services/audio.nix
    ./services/bluetooth.nix
    ./services/flatpak.nix
    ./programs/fonts.nix
    ./programs/filemanager.nix

    ./desktop/common.nix
    ./desktop/hyprland.nix

    ./performance/optimizations.nix

    ./users.nix
  ];
}
