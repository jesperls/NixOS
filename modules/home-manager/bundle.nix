{ osConfig, ... }:

{
  imports = [
    ./cli/environment.nix
    ./cli/zsh.nix
    ./cli/ssh.nix
    ./cli/cli.nix

    ./desktop/xdg.nix
    ./desktop/theme.nix
    ./desktop/mimeapps.nix
    ./desktop/hyprland
    ./desktop/shell.nix

    ./programs/firefox.nix
    ./programs/flatpak.nix
    ./programs/nixcord.nix
    ./programs/obs.nix
    ./programs/spicetify.nix
    ./programs/easyeffects.nix

    ./services/desktop-autostarts.nix
    ./services/deltatune.nix
    ./services/home-assistant.nix
  ];

  home.stateVersion = osConfig.mySystem.home.stateVersion;
}
