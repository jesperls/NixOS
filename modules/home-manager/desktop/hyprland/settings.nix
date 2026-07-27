{
  lib,
  osConfig,
  ...
}:
let
  cursorTheme = osConfig.mySystem.theme.gtk.cursorTheme;
  special = osConfig.mySystem.desktop.specialWorkspaces;

  mkCall = args: { _args = args; };

  monitorWidth = monitor: lib.toInt (builtins.head (lib.splitString "x" monitor.resolution));

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
          sdrbrightness
          sdrsaturation
          ;
      }
      // lib.optionalAttrs (monitor.vrr != 0) { inherit (monitor) vrr; }
    );

  activeMonitors = builtins.filter (monitor: !monitor.disabled) osConfig.mySystem.monitors;
  numMonitors = builtins.length activeMonitors;

  mkWorkspaceRule = index: {
    workspace = toString (index + 1);
    monitor = (builtins.elemAt activeMonitors (lib.mod index numMonitors)).name;
    default = true;
  };

  specialWorkspaceRules =
    let
      width = monitorWidth (builtins.head activeMonitors);
      sideGap = (width - special.maxWidth) / 2;
    in
    lib.optionals (numMonitors > 0 && special.maxWidth > 0 && width > special.maxWidth) (
      map
        (workspace: {
          inherit workspace;
          gaps_out = {
            left = sideGap;
            right = sideGap;
            top = special.verticalGap;
            bottom = special.verticalGap;
          };
        })
        [
          "special:magic"
          "special:scratchpad"
        ]
    );
in
{
  env =
    lib.mapAttrsToList
      (
        name: value:
        mkCall [
          name
          value
        ]
      )
      {
        HYPRCURSOR_THEME = cursorTheme.name;
        HYPRCURSOR_SIZE = toString cursorTheme.size;
      };

  monitor = (map renderMonitor osConfig.mySystem.monitors) ++ [
    {
      output = "";
      mode = "preferred";
      position = "auto";
      scale = 1;
    }
  ];

  workspace_rule =
    lib.optionals (numMonitors > 0) (lib.genList mkWorkspaceRule 10) ++ specialWorkspaceRules;
}
