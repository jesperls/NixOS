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
      allowedTCPPorts = [ 12345 ];
    };

    nftables.enable = true;
  };

  services.openssh = {
    enable = false;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  systemd.services.NetworkManager-wait-online.enable = lib.mkDefault false;
}
