{ config, lib, ... }:

{
  options.mySystem.desktop = {
    shell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Run Pangu, the Quickshell desktop shell (desktop hosts enable this by importing desktop/bundle.nix).";
      };

      wallpapers = lib.mkOption {
        type = lib.types.str;
        default = "/home/${config.mySystem.user.username}/Pictures/Wallpapers";
        description = "Wallpaper library the shell's picker defaults to.";
      };

      settings = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
        default = { };
        example = {
          bar.position = "top";
        };
        description = "Per-file shell settings merged into runtime JSON on every shell start.";
      };
    };

    specialWorkspaces = {
      maxWidth = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 2560;
        description = "Maximum logical width of special workspaces; zero uses the full monitor.";
      };
      verticalGap = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 30;
        description = "Top/bottom gap for padded special workspaces.";
      };
    };

    input = {
      accelProfile = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "flat"
            "adaptive"
          ]
        );
        default = null;
        description = "Pointer acceleration profile; null keeps the device default.";
      };
      repeatRate = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 40;
        description = "Key repeats per second once repeating starts.";
      };
      repeatDelay = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 300;
        description = "Milliseconds a key must be held before it starts repeating.";
      };
      numlockByDefault = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Turn Num Lock on when the session starts.";
      };
    };

    render = {
      directScanout = lib.mkOption {
        type = lib.types.enum [
          0
          1
          2
        ];
        default = 2;
        description = "Direct scanout mode: zero disables it, one allows all fullscreen apps, two allows games.";
      };
    };

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

    layouts = {
      default = lib.mkOption {
        type = lib.types.str;
        default = "dwindle";
        description = "Initial workspace layout, with a lua: prefix for Lua-defined layouts.";
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
          type = lib.types.addCheck lib.types.number (value: value > 0 && value < 1);
          default = 0.50;
          description = "Fraction of the workspace width the fixed centered master column occupies.";
        };
        fullHeight = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Extend the centered master to the full monitor height at a fixed aspect ratio.";
        };
        fullHeightAspect = lib.mkOption {
          type = lib.types.addCheck (lib.types.listOf lib.types.ints.positive) (
            value: builtins.length value == 2
          );
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
        description = "Affected window classes; an empty list uses the default browser.";
      };
    };
  };
}
