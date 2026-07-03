{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.${config.mySystem.user.username} = {
    isNormalUser = true;
    description = config.mySystem.user.fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "input"
      "storage"
      "gamemode"
    ]
    ++ lib.optional config.virtualisation.docker.enable "docker";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = [
      ""
      "@${pkgs.util-linux}/sbin/agetty agetty --autologin ${config.mySystem.user.username} --noclear %I $TERM"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
}
