{ config, lib, ... }:

{
  networking = {
    hostName = config.mySystem.system.hostName;

    networkmanager.enable = true;

    firewall.enable = false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  systemd.services.NetworkManager-wait-online.enable = lib.mkDefault false;
}
