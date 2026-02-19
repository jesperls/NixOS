{ ... }:
{
  imports = [
    ./cli/environment.nix
    ./cli/zsh.nix
    ./cli/cli.nix
    ./desktop/xdg.nix
    ./desktop/theme.nix
    ./desktop/mimeapps.nix
    ./desktop/hyprland.nix
    ./desktop/caelestia.nix
    ./desktop/wallpaper-picker.nix
    ./programs/firefox.nix
    ./programs/vesktop.nix
    ./programs/spicetify.nix
    ./programs/myna.nix
    ./programs/obs.nix
    ./programs/easyeffects.nix
    ./services/bonecontrol-listener.nix
    ./services/deltatune.nix
    ./programs/quickshell-package-manager.nix
    ./packages.nix
  ];
}
