{ ... }:

{
  imports = [
    ./options

    ./core/boot.nix
    ./core/network.nix
    ./core/nix.nix
    ./core/locale.nix

    ./services/flatpak.nix
    ./services/dlna.nix
    ./services/docker.nix
    ./services/ollama.nix
    ./services/home-assistant.nix
    ./services/sunshine.nix
    ./programs/gaming.nix
    ./programs/lutris.nix
    ./programs/coolercontrol.nix
    ./programs/filemanager.nix

    ./hardware/nvidia.nix
    ./hardware/vial.nix
    ./hardware/webcam.nix
    ./hardware/sensors.nix

    ./performance/optimizations.nix
    ./performance/scheduling.nix
    ./performance/autofdo.nix

    ./home-manager.nix
    ./users.nix
  ];
}
