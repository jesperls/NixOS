{ ... }:

{
  imports = [
    ../../modules/home-manager/bundle.nix

    ./packages.nix
  ];

  home.stateVersion = "26.05";
}
