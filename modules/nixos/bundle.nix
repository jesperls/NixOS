{ ... }:

{
  imports = [
    ./options

    ./core/boot.nix
    ./core/network.nix
    ./core/nix.nix
    ./core/locale.nix

    ./performance/optimizations.nix
    ./performance/scheduling.nix

    ./home-manager.nix
    ./users.nix
  ];
}
