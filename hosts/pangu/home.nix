{ osConfig, ... }:

{
  imports = [
    ../../modules/home-manager/cli/environment.nix
    ../../modules/home-manager/cli/zsh.nix
    ../../modules/home-manager/cli/ssh.nix
    ../../modules/home-manager/cli/cli.nix
    ../../modules/home-manager/desktop/xdg.nix
    ../../modules/home-manager/desktop/theme.nix
    ../../modules/home-manager/desktop/mimeapps.nix
    ../../modules/home-manager/desktop/hyprland.nix
    ../../modules/home-manager/desktop/wallpaper.nix
    ../../modules/home-manager/programs/firefox.nix
    ../../modules/home-manager/programs/flatpak.nix
    ../../modules/home-manager/programs/spicetify.nix
    ../../modules/home-manager/programs/nixcord.nix
    ../../modules/home-manager/programs/obs.nix
    ../../modules/home-manager/programs/claude-code.nix
    ../../modules/home-manager/programs/easyeffects.nix
    ../../modules/home-manager/programs/quickshell-package-manager.nix
    ../../modules/home-manager/programs/qs-vpets.nix
    ../../modules/home-manager/services/deltatune.nix
    ../../modules/home-manager/services/desktop-autostarts.nix
    ./packages.nix
  ];

  home.stateVersion = osConfig.mySystem.home.stateVersion;
}
