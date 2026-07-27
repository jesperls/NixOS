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

    ./services/desktop-autostarts.nix
    ./services/home-assistant.nix
  ];

  home.stateVersion = osConfig.mySystem.home.stateVersion;
}
