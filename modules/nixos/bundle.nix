{ ... }:

{
  imports = [
    # Core System Configuration
    ./core/boot.nix
    ./core/network.nix
    ./core/nix.nix
    ./core/options.nix
    ./core/locale.nix
    ./core/theme.nix

    # Hardware Support
    ./hardware/nvidia.nix
    ./hardware/vial.nix

    # System Services
    ./services/audio.nix
    ./services/bluetooth.nix
    ./services/backup.nix
    ./services/flatpak.nix

    # Programs & Applications
    ./programs/gaming.nix
    ./programs/fonts.nix
    ./programs/filemanager.nix

    # Desktop Environment
    ./desktop/common.nix
    ./desktop/hyprland.nix

    # Performance & Optimization
    ./performance/optimizations.nix

    # User Management
    ./users.nix
  ];
}
