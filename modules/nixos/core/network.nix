{ config, lib, ... }:

let
  ipHostEntries = builtins.filter (
    entry:
    builtins.match "^([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+|[0-9a-fA-F:]*:[0-9a-fA-F:]+)$" entry.value.address
    != null
  ) (lib.attrsToList config.mySystem.network.hosts);
in
{
  networking = {
    hostName = config.mySystem.system.hostName;
    networkmanager.enable = true;
    hosts = lib.mapAttrs (_: map (entry: entry.name)) (
      lib.groupBy (entry: entry.value.address) ipHostEntries
    );
    firewall = {
      allowedTCPPorts = config.mySystem.network.allowedTCPPorts;
      allowedUDPPorts = config.mySystem.network.allowedUDPPorts;
    };
  };

  services.openssh = {
    startWhenNeeded = true;
    openFirewall = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  systemd.services.NetworkManager-wait-online.enable = lib.mkDefault false;
}
