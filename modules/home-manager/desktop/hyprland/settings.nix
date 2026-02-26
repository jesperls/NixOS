{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
{

  settings = {
    env = [
      "XCURSOR_THEME,${osConfig.mySystem.theme.gtk.cursorTheme.name}"
      "XCURSOR_SIZE,${builtins.toString osConfig.mySystem.theme.gtk.cursorTheme.size}"
      "HYPRCURSOR_THEME,${osConfig.mySystem.theme.gtk.cursorTheme.name}"
      "HYPRCURSOR_SIZE,${builtins.toString osConfig.mySystem.theme.gtk.cursorTheme.size}"
    ];

    exec-once = [
      "solaar -w hide"
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
      "qpwgraph -m"
      "systemctl --user start hyprpolkitagent"
    ];

    general = {
      gaps_in = osConfig.mySystem.theme.gaps.inner;
      gaps_out = osConfig.mySystem.theme.gaps.outer;
      border_size = osConfig.mySystem.theme.borders;
      "col.active_border" =
        let
          t = osConfig.mySystem.theme;
          c1 = lib.removePrefix "#" t.colors.activeBorder;
          a = t.opacity.activeBorder;
        in
        if t.borderGradient.enable then
          "rgba(${c1}${a}) rgba(${lib.removePrefix "#" t.borderGradient.secondColor}${a}) ${toString t.borderGradient.angle}deg"
        else
          "rgba(${c1}${a})";
      "col.inactive_border" =
        "rgba(${lib.removePrefix "#" osConfig.mySystem.theme.colors.inactiveBorder}${osConfig.mySystem.theme.opacity.inactiveBorder})";
      layout = "dwindle";
      resize_on_border = true;
    };

    decoration = {
      rounding = osConfig.mySystem.theme.rounding;
      blur = {
        enabled = true;
        size = 5;
        passes = 2;
        new_optimizations = true;
        ignore_opacity = true;
        xray = true;
      };
      shadow = {
        enabled = false;
      };
    };

    animations = {
      enabled = true;
      bezier = [
        "easeOutQuint,0.23,1,0.32,1"
        "easeInOutQuint,0.83,0,0.17,1"
        "sharpBounce,0.76,0,0.24,1.1"
      ];
      animation = [
        "windows,1,3,easeOutQuint,slide"
        "windowsOut,1,3,easeInOutQuint,slide"
        "fade,1,4,easeInOutQuint"
      ];
    };

    input = {
      kb_layout = osConfig.mySystem.system.keyboardLayout;
      follow_mouse = 1;
      touchpad = {
        natural_scroll = true;
      };
      sensitivity = 0;
    };

    cursor = {
      no_hardware_cursors = true;
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      mouse_move_enables_dpms = true;
      key_press_enables_dpms = true;
    };

    monitor =
      let
        renderMonitor =
          m:
          if m.disabled then
            "${m.name}, disable"
          else
            "${m.name}, ${m.resolution}@${toString m.refreshRate}, ${m.position}, ${m.scale}"
            + (if m.transform != null then ", transform, ${toString m.transform}" else "");
        catchAll = ", preferred, auto, 1";
      in
      (map renderMonitor osConfig.mySystem.monitors) ++ [ catchAll ];

    workspace =
      let
        monitors = osConfig.mySystem.monitors;
        numMonitors = builtins.length monitors;
        mkWorkspace =
          i:
          let
            mon = builtins.elemAt monitors (lib.mod i numMonitors);
          in
          "${toString (i + 1)}, monitor:${mon.name}, default:true";
      in
      lib.genList mkWorkspace 9;
  };
}
