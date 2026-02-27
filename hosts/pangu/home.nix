{ osConfig, ... }:

{
  imports = [
    ../../modules/home-manager/cli/environment.nix
    ../../modules/home-manager/cli/zsh.nix
    ../../modules/home-manager/cli/cli.nix
    ../../modules/home-manager/desktop/xdg.nix
    ../../modules/home-manager/desktop/theme.nix
    ../../modules/home-manager/desktop/mimeapps.nix
    ../../modules/home-manager/desktop/hyprland.nix
    ../../modules/home-manager/desktop/caelestia.nix
    ../../modules/home-manager/desktop/wallpaper-picker.nix
    ../../modules/home-manager/programs/firefox.nix
    ../../modules/home-manager/programs/vesktop.nix
    ../../modules/home-manager/programs/spicetify.nix
    ../../modules/home-manager/programs/myna.nix
    ../../modules/home-manager/programs/obs.nix
    ../../modules/home-manager/programs/easyeffects.nix
    ../../modules/home-manager/services/bonecontrol-listener.nix
    ../../modules/home-manager/services/deltatune.nix
    ../../modules/home-manager/programs/quickshell-package-manager.nix
    ./packages.nix
  ];

  home.stateVersion = osConfig.mySystem.system.stateVersion;
}
