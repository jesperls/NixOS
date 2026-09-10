{ osConfig, ... }:

{
  imports = [
    ./cli/environment.nix
    ./cli/zsh.nix
    ./cli/ssh.nix
    ./cli/tools.nix
    ./cli/git.nix
  ];

  home.stateVersion = osConfig.mySystem.home.stateVersion;
}
