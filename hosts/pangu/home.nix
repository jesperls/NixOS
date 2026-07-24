{ ... }:

{
  imports = [
    ../../modules/home-manager/bundle.nix

    ../../modules/home-manager/desktop/wallpaper.nix
    ../../modules/home-manager/programs/spicetify.nix
    ../../modules/home-manager/programs/nixcord.nix
    ../../modules/home-manager/programs/obs.nix
    ../../modules/home-manager/programs/claude-code.nix
    ../../modules/home-manager/programs/easyeffects.nix
    ../../modules/home-manager/programs/quickshell-package-manager.nix
    ../../modules/home-manager/programs/qs-vpets.nix
    ../../modules/home-manager/services/deltatune.nix

    ./packages.nix
  ];
}
