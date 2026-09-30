{ lib, pkgs }:

let
  defaults = {
    resolution = "5120x1440";
    refreshRate = 240;
    position = "0x0";
    scale = 1;
    transform = null;
    disabled = false;
    vrr = 0;
    bitdepth = null;
    cm = null;
    sdrBrightness = null;
    sdrSaturation = null;
  };
  monitor = name: overrides: defaults // { inherit name; } // overrides;
  layout =
    monitors:
    import ../modules/home-manager/desktop/hyprland/settings.nix {
      inherit lib;
      osConfig.mySystem = {
        inherit monitors;
        theme.gtk.cursorTheme = {
          name = "test";
          size = 24;
        };
        desktop.specialWorkspaces = {
          maxWidth = 2560;
          verticalGap = 30;
        };
      };
    };
  empty = layout [ ];
  disabled = layout [ (monitor "disabled" { disabled = true; }) ];
  single = layout [ (monitor "one" { }) ];
  multiple = layout [
    (monitor "disabled" { disabled = true; })
    (monitor "one" { })
    (monitor "two" { })
    (monitor "three" { })
  ];
  scaled = layout [ (monitor "scaled" { scale = 2; }) ];
  rotated = layout [ (monitor "rotated" { transform = 1; }) ];
  numericRules = builtins.filter (rule: builtins.match "[0-9]+" rule.workspace != null);
in
assert empty.primary == null && empty.primaryWorkspaces == [ ];
assert empty.settings.workspace_rule == [ ];
assert disabled.primary == null && disabled.settings.workspace_rule == [ ];
assert single.primaryWorkspaces == lib.range 1 10;
assert
  multiple.primary == "one"
  &&
    multiple.primaryWorkspaces == [
      1
      4
      7
      10
    ];
assert
  map (rule: rule.monitor) (numericRules multiple.settings.workspace_rule) == [
    "one"
    "two"
    "three"
    "one"
    "two"
    "three"
    "one"
    "two"
    "three"
    "one"
  ];
assert builtins.length single.settings.workspace_rule == 11;
assert (lib.last single.settings.workspace_rule).gaps_out.left == 1280;
assert builtins.length scaled.settings.workspace_rule == 10;
assert builtins.length rotated.settings.workspace_rule == 10;
pkgs.runCommand "desktop-contract-check" { } ''
  touch "$out"
''
