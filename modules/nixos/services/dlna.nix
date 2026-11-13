{ config, lib, ... }:

{
  services.minidlna = {
    enable = true;
    openFirewall = true;
    settings = {
      friendly_name = lib.mkDefault "${config.mySystem.system.hostName} media";
      inotify = "yes";
    };
  };

  users.users.minidlna.extraGroups = [ "users" ];
  systemd.services.minidlna.serviceConfig.PrivateUsers = lib.mkForce false; # user namespaces drop supplementary groups

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    settings.publish = {
      disable-publishing = false;
      publish-addresses = true;
      publish-workstation = true;
    };
  };
}
