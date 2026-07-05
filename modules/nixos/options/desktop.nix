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
          default = 0.55;
          description = "Fraction of the workspace width the centered master column occupies.";
        };
        masterWidthMin = lib.mkOption {
          type = lib.types.numbers.between 0.0 1.0;
          default = 0.2;
          description = "Lower bound when resizing the master column.";
        };
        masterWidthMax = lib.mkOption {
          type = lib.types.numbers.between 0.0 1.0;
          default = 0.8;
          description = "Upper bound when resizing the master column.";
        };
        resizeStep = lib.mkOption {
          type = lib.types.numbers.between 0.0 1.0;
          default = 0.05;
          description = "How much the master width changes per resize keypress.";
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
