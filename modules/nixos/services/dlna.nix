{ config, lib, ... }:

let
  cfg = config.mySystem.services.dlna;
in
{
  options.mySystem.services.dlna = {
    enable = lib.mkEnableOption "the minidlna media server and mDNS discovery";

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

  config = lib.mkIf cfg.enable {
    services.minidlna = {
      enable = true;
      openFirewall = true;
      settings = {
        friendly_name = cfg.friendlyName;
        media_dir = cfg.mediaDirs;
        log_level = "error";
      };
    };

    # minidlna reads the library as its own user, so it needs a group that the
    # media directories are actually readable by.
    users.users.minidlna.extraGroups = [ "users" ];

    # DLNA clients reply to SSDP discovery on minidlna's ephemeral source port
    # rather than to the advertised port.
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 32768;
        to = 61000;
      }
    ];

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
