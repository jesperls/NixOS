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
      "systemctl --user start hyprpolkitagent"
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
      "qpwgraph -m"
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
      "col.inactive_border" = "rgba(${lib.removePrefix "#" osConfig.mySystem.theme.colors.inactiveBorder}${osConfig.mySystem.theme.opacity.inactiveBorder})";
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

    monitor = osConfig.mySystem.monitors;

    workspace = [
      "1, monitor:HDMI-A-1, default:true"
      "2, monitor:DP-3, default:true"
      "3, monitor:DP-2, default:true"
      "4, monitor:HDMI-A-1, default:true"
      "5, monitor:DP-3, default:true"
      "6, monitor:DP-2, default:true"
      "7, monitor:HDMI-A-1, default:true"
      "8, monitor:DP-3, default:true"
      "9, monitor:DP-2, default:true"
    ];
  };
}
