{ config, lib, ... }:

let
  cfg = config.mySystem.services.dlna;
in
{
  options.mySystem.services.dlna = {
    friendlyName = lib.mkOption {
      type = lib.types.str;
      default = "${config.mySystem.system.hostName} media";
      description = "Name the server advertises to DLNA clients.";
    };

    mediaDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "V,/srv/media/videos" ];
      description = "minidlna media_dir entries (`<A|P|V>,<path>`, type prefix optional).";
    };
  };

  config = {
    services.minidlna = {
      enable = true;
      openFirewall = true;
      settings = {
        friendly_name = cfg.friendlyName;
        media_dir = cfg.mediaDirs;
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
  };
}
