{ config, ... }:

{
  networking = {
    hostName = config.mySystem.system.hostName;
    networkmanager.enable = true;

    firewall.enable = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;
}
