{
  config,
  lib,
  ...
}:

{
  networking = {
    hostName = config.mySystem.system.hostName;

    networkmanager = {
      enable = true;
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 12345 ];
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
