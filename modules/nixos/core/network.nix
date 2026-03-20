{ config, lib, ... }:

{
  networking = {
    hostName = config.mySystem.system.hostName;

    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        12345 # bonecontrol-listener
      ];
    };

    nftables.enable = true;
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
