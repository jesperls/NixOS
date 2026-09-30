{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.pangu-shell.nixosModules.default ];

  programs.pangu = {
    enable = config.mySystem.desktop.shell.enable;
    package = pkgs.pangu;
    users = [ config.mySystem.user.username ];
  };
}
