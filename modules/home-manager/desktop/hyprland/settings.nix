{
  lib,
  osConfig,
  ...
}:
let
  cursorTheme = osConfig.mySystem.theme.gtk.cursorTheme;
  mkCall = args: { _args = args; };
  renderMonitor =
    monitor:
    {
      output = monitor.name;
      disabled = monitor.disabled;
    }
    // lib.optionalAttrs (!monitor.disabled) {
      mode = "${monitor.resolution}@${toString monitor.refreshRate}";
      position = monitor.position;
      scale = monitor.scale;
    }
    // lib.optionalAttrs (!monitor.disabled && monitor.transform != null) {
      transform = monitor.transform;
    }
    // lib.optionalAttrs (!monitor.disabled && monitor.vrr != 0) {
      vrr = monitor.vrr;
    }
    // lib.optionalAttrs (!monitor.disabled && monitor.bitdepth != null) {
      bitdepth = monitor.bitdepth;
    };
  monitors = osConfig.mySystem.monitors;
  activeMonitors = builtins.filter (monitor: !monitor.disabled) monitors;
  numMonitors = builtins.length activeMonitors;
  mkWorkspaceRule =
    index:
    let
      monitor = builtins.elemAt activeMonitors (lib.mod index numMonitors);
    in
    {
      workspace = toString (index + 1);
      monitor = monitor.name;
      default = true;
    };
  monitorWidth = monitor: lib.toInt (builtins.head (lib.splitString "x" monitor.resolution));
  specialWorkspaceRules =
    if numMonitors == 0 then
      [ ]
    else
      let
        width = monitorWidth (builtins.head activeMonitors);
        sideGap = (width - 2560) / 2;
      in
      lib.optionals (width > 3440) (
        map (workspace: {
          inherit workspace;
          gaps_out = {
            left = sideGap;
            right = sideGap;
            top = 30;
            bottom = 30;
          };
        })
          [
            "special:magic"
            "special:scratchpad"
          ]
      );
in
{
  env = [
    (mkCall [
      "XCURSOR_THEME"
      cursorTheme.name
    ])
    (mkCall [
      "XCURSOR_SIZE"
      (toString cursorTheme.size)
    ])
    (mkCall [
      "HYPRCURSOR_THEME"
      cursorTheme.name
    ])
    (mkCall [
      "HYPRCURSOR_SIZE"
      (toString cursorTheme.size)
    ])
  ];

  monitor = (map renderMonitor monitors) ++ [
    {
      output = "";
      mode = "preferred";
      position = "auto";
      scale = 1;
    }
  ];

  workspace_rule =
    (if numMonitors == 0 then [ ] else lib.genList mkWorkspaceRule 9) ++ specialWorkspaceRules;
}
