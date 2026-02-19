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
      wifi.powersave = true;
    };

    firewall = {
      enable = false;
      allowPing = true;
      allowedTCPPorts = [ 22 12345 47984 47989 48010 ];
      allowedUDPPorts = [ 47998 47999 47800 ];
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
