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

    idle = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run idle actions (dim, screen off, suspend, and idle lock) after periods of inactivity. When disabled, no idle timers fire at all.";
      };
      dimTimeout = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 150;
        description = "Seconds of inactivity before the screen dims. 0 disables dimming.";
      };
      dimBrightness = lib.mkOption {
        type = lib.types.ints.between 0 100;
        default = 10;
        description = "Brightness percentage to dim to when idle.";
      };
      lockTimeout = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 300;
        description = "Seconds of inactivity before locking the screen. Only takes effect when desktop.lockscreen.enable is true. 0 disables the idle lock even when the lockscreen is enabled.";
      };
      screenOffTimeout = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 330;
        description = "Seconds of inactivity before turning the display off (DPMS). 0 disables.";
      };
      suspendTimeout = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 1800;
        description = "Seconds of inactivity before suspending the system. 0 disables idle suspend.";
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

    layouts = {
      default = lib.mkOption {
        type = lib.types.str;
        default = "dwindle";
        description = "Layout workspaces start in. Lua-defined layouts use the lua: prefix.";
      };
      cycle = lib.mkOption {
        type = lib.types.nonEmptyListOf lib.types.str;
        default = [
          "dwindle"
          "lua:centered"
        ];
        description = "Layouts the per-workspace layout keybind cycles through, in order.";
      };
      centered = {
        masterWidth = lib.mkOption {
          type = lib.types.numbers.between 0.0 1.0;
          default = 0.50;
          description = "Fraction of the workspace width the fixed centered master column occupies.";
        };
        fullHeight = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Make the centered master span the full monitor height at a fixed aspect ratio, extending over the bar's reserved area. The bar is expected to split around it (Ambxst listens for the centergap event).";
        };
        fullHeightAspect = lib.mkOption {
          type = lib.types.listOf lib.types.int;
          default = [
            16
            9
          ];
          description = "Aspect ratio (width height) of the full-height centered master.";
        };
        heightResizeStep = lib.mkOption {
          type = lib.types.numbers.between 0.0 2.0;
          default = 0.15;
          description = "How much a side window's height weight changes per resize keypress.";
        };
      };
    };

    autoFakeFullscreen = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Demote fullscreen to client-only (window-contained) when the window shares its workspace with other tiled windows.";
      };
      classes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Window classes this applies to. Empty means the default browser.";
      };
    };
  };
}
