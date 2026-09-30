{
  lib,
  osConfig,
  ...
}:
let
  special = osConfig.mySystem.desktop.specialWorkspaces;

  cursorTheme = osConfig.mySystem.theme.gtk.cursorTheme;
  mkCall = args: { _args = args; };

  monitorWidth =
    monitor:
    let
      dimensions = lib.splitString "x" monitor.resolution;
      axis =
        if
          builtins.elem monitor.transform [
            1
            3
            5
            7
          ]
        then
          1
        else
          0;
    in
    (lib.toInt (builtins.elemAt dimensions axis)) / monitor.scale;

  renderMonitor =
    monitor:
    {
      output = monitor.name;
      disabled = monitor.disabled;
    }
    // lib.optionalAttrs (!monitor.disabled) (
      {
        mode = "${monitor.resolution}@${toString monitor.refreshRate}";
        inherit (monitor) position scale;
      }
      // lib.filterAttrs (_: value: value != null) {
        inherit (monitor)
          transform
          bitdepth
          cm
          ;
        sdrbrightness = monitor.sdrBrightness;
        sdrsaturation = monitor.sdrSaturation;
      }
      // lib.optionalAttrs (monitor.vrr != 0) { inherit (monitor) vrr; }
    );

  activeMonitors = builtins.filter (monitor: !monitor.disabled) osConfig.mySystem.monitors;
  numMonitors = builtins.length activeMonitors;

  mkWorkspaceRule = index: {
    workspace = toString (index + 1);
    monitor = (builtins.elemAt activeMonitors (lib.mod index numMonitors)).name;
    default = index < numMonitors;
  };
  workspaceRules = lib.optionals (numMonitors > 0) (lib.genList mkWorkspaceRule 10);
  primary = if activeMonitors == [ ] then null else (builtins.head activeMonitors).name;

  specialWorkspaceRules =
    let
      width = monitorWidth (builtins.head activeMonitors);
      sideGap = (width - special.maxWidth) / 2;
    in
    lib.optionals (numMonitors > 0 && special.maxWidth > 0 && width > special.maxWidth) (
      map (workspace: {
        inherit workspace;
        gaps_out = {
          left = sideGap;
          right = sideGap;
          top = special.verticalGap;
          bottom = special.verticalGap;
        };
      }) [ "special:scratchpad" ]
    );

in
{
  primaryWorkspaces = map (rule: lib.toInt rule.workspace) (
    builtins.filter (rule: rule.monitor == primary) workspaceRules
  );
  inherit primary;

  settings = {
    env = [
      (mkCall [
        "HYPRCURSOR_THEME"
        cursorTheme.name
      ])
      (mkCall [
        "HYPRCURSOR_SIZE"
        (toString cursorTheme.size)
      ])
    ];

    monitor = (map renderMonitor osConfig.mySystem.monitors) ++ [
      {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      }
    ];

    workspace_rule = workspaceRules ++ specialWorkspaceRules;
  };
}
