{ config, pkgs, lib, osConfig, ... }: {

  settings = {
  exec-once = [
    "systemctl --user start swww"
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
      "col.active_border" = "rgba(${lib.removePrefix "#" osConfig.mySystem.theme.colors.accent}ee) rgba(${lib.removePrefix "#" osConfig.mySystem.theme.colors.accent2}ee) 45deg";
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
      #"border,1,8,easeInOutQuint"
      #"borderangle,1,30,easeInOutQuint"
      "fade,1,4,easeInOutQuint"
      #"workspaces,1,8,easeOutQuint,slide"
      #"specialWorkspace,1,8,easeOutQuint,slide"
    ];
  };

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
  };
}
