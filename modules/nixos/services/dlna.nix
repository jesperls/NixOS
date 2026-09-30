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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
