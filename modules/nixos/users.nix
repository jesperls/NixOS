{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem;
in
{
  users.users.${cfg.user.username} = {
    isNormalUser = true;
    description = cfg.user.fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "input"
    ]
    ++ lib.optional config.virtualisation.docker.enable "docker"
    ++ lib.optional config.programs.gamemode.enable "gamemode";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  systemd.services."getty@tty1" = lib.mkIf cfg.system.autoLogin {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = [
      ""
      "@${pkgs.util-linux}/sbin/agetty agetty --autologin ${cfg.user.username} --noclear %I $TERM"
    ];
  };

  security.sudo.wheelNeedsPassword = !cfg.system.passwordlessSudo;
}
