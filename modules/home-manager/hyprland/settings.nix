{ config, pkgs, lib, osConfig, ... }: {
  exec-once = [
    "systemctl --user start swww"
    "solaar -w hide"
    "systemctl --user start hyprpolkitagent"
    "wl-paste --type text --watch cliphist store"
    "wl-paste --type image --watch cliphist store"
    "qpwgraph -m"
  ];

  general = {
    gaps_in = 0;
    gaps_out = 0;
    border_size = osConfig.mySystem.theme.borders;
    "col.active_border" = "rgba(${
        lib.removePrefix "#" osConfig.mySystem.theme.colors.accent
      }ee) rgba(${
        lib.removePrefix "#" osConfig.mySystem.theme.colors.accent2
      }ee) 45deg";
    "col.inactive_border" =
      "rgba(${lib.removePrefix "#" osConfig.mySystem.theme.colors.surface}aa)";
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
    shadow = { enabled = false; };
  };

  animations = { enabled = true; };

  input = {
    kb_layout = osConfig.mySystem.system.keyboardLayout;
    follow_mouse = 1;
    touchpad = { natural_scroll = true; };
    sensitivity = 0;
  };

  cursor = { no_hardware_cursors = true; };

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
}
