{ lib, ... }:

{
  options.mySystem.desktop = {
    lockscreen = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the desktop lockscreen.";
      };
      lockOnSleep = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Lock the screen before the system goes to sleep.";
      };
      lockOnBoot = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Lock the screen automatically when the session starts.";
      };
    };

    gaming = {
      tearing = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Allow tearing (immediate page flips) for matching fullscreen games to minimize latency.";
        };
        classPatterns = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "^(steam_app_\\d+)$" ];
          description = "Window class regexes that get the immediate (tearing) window rule.";
        };
      };
    };
  };
}
