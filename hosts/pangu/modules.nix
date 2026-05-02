{ ... }:

{
  imports = [
    ../../modules/nixos/hardware/nvidia.nix
    ../../modules/nixos/hardware/vial.nix
    ../../modules/nixos/hardware/webcam.nix
    ../../modules/nixos/hardware/sensors.nix
    ../../modules/nixos/hardware/logitech.nix

    ../../modules/nixos/services/sunshine.nix

    ../../modules/nixos/programs/gaming.nix
    ../../modules/nixos/programs/lutris.nix
  ];
}
