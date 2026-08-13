{ config, ... }:

{
  networking = {
    hostName = config.mySystem.system.hostName;
    networkmanager.enable = true;
  };

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
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
