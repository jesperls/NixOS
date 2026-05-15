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
    };
  monitors = osConfig.mySystem.monitors;
  numMonitors = builtins.length monitors;
  mkWorkspaceRule =
    index:
    let
      monitor = builtins.elemAt monitors (lib.mod index numMonitors);
    in
    {
      workspace = toString (index + 1);
      monitor = monitor.name;
      default = true;
    };
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

  workspace_rule = if numMonitors == 0 then [ ] else lib.genList mkWorkspaceRule 9;
}
