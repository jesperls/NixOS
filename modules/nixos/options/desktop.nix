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
        description = ''
          Per-file overrides for ~/.config/pangu/config/<name>.json, merged in
          every time the shell starts. The shell writes those files back at
          runtime, so they cannot be store symlinks: anything declared here is
          re-asserted on start and left editable in between. Keys not mentioned
          keep whatever the user set in the GUI, and keys in neither fall back
          to the schema in share/shell/config/Config.qml.
        '';
      };
    };

    specialWorkspaces = {
      maxWidth = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 2560;
        description = ''
          Width special workspaces are padded down to on wider monitors, so
          they stay a readable centered column instead of spanning an
          ultrawide. 0 lets them use the full width.
        '';
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
        description = ''
          Pointer acceleration. "flat" is 1:1 raw movement, "adaptive" is
          libinput's speed-dependent curve, null keeps the device default.
        '';
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
        description = ''
          Scan fullscreen buffers out directly, skipping composition.
          0 off, 1 always, 2 only for game content type.
        '';
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
          type = lib.types.addCheck lib.types.number (value: value > 0 && value < 1);
          default = 0.50;
          description = "Fraction of the workspace width the fixed centered master column occupies.";
        };
        fullHeight = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Make the centered master span the full monitor height at a fixed aspect ratio, extending over the bar's reserved area. The bar is expected to split around it (Pangu listens for the centergap event).";
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
        description = "Window classes this applies to. Empty means the default browser.";
      };
    };
  };
}
