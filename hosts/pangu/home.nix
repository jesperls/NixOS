{ ... }:

{
  imports = [
    ../../modules/home-manager/bundle.nix

    ./packages.nix
    ./cli.nix
  ];
}
