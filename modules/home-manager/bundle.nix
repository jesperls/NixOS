{ osConfig, ... }:

{
  imports = [
    ./cli/environment.nix
    ./cli/zsh.nix
    ./cli/ssh.nix
    ./cli/cli.nix

    ./programs/flatpak.nix
    ./services/home-assistant.nix
  ];

  home.stateVersion = osConfig.mySystem.home.stateVersion;
}
