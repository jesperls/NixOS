{ config, pkgs, osConfig, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [
        "waybar"
        "swaync"
        "systemctl --user start swww"
        "solaar -w hide"
        "systemctl --user start hyprpolkitagent"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "qpwgraph -m"
      ];

      "$terminal" = "kitty";
      "$browser" = "firefox";
      "$mainMod" = "SUPER";

      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 0;
        "col.active_border" = "rgba(89b4faee) rgba(cba6f7ee) 45deg";
        "col.inactive_border" = "rgba(585b70aa)";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 0;
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
        #bezier = [
        #"wind, 0.05, 0.9, 0.1, 1.05"
        #"winIn, 0.1, 1.1, 0.1, 1.1"
        #"winOut, 0.3, -0.3, 0, 1"
        #"liner, 1, 1, 1, 1"
        #];
        #animation = [
        #"windows, 1, 6, wind, slide"
        #"windowsIn, 1, 6, winIn, slide"
        #"windowsOut, 1, 5, winOut, slide"
        #"windowsMove, 1, 5, wind, slide"
        #"border, 1, 1, liner"
        #"borderangle, 1, 30, liner, loop"
        #"fade, 1, 10, default"
        #"workspaces, 1, 5, wind"
        #];
      };

      input = {
        kb_layout = "se";
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

      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        "float,class:^(blueman-manager)$"
        "float,class:^(nm-connection-editor)$"
        "float,class:^(org.gnome.Calculator)$"
        "float,class:^(org.gnome.NautilusPreviewer)$"
        "float,class:^(eog)$"
        "float,class:^(vlc)$"
        "float,class:^(imv)$"
        "float,title:^(Picture-in-Picture)$"
        "pin,title:^(Picture-in-Picture)$"
        "opacity 0.9 0.9,class:^(kitty)$"
      ];

      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, E, exec, thunar"
        "$mainMod, A, exec, rofi -show drun"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, D, exec, vesktop"
        "$mainMod, B, exec, $browser"
        "$mainMod, W, togglefloating"
        "$mainMod, F, fullscreen"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"

        # Wallpaper controls
        "$mainMod SHIFT, W, exec, wallpaper-switcher"
        "$mainMod SHIFT, R, exec, wallpaper-manager random"

        # Focus movement
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Move windows
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"

        # Screenshots
        ''$mainMod, S, exec, grim -g "$(slurp -w 0)" - | wl-copy''
        ''
          $mainMod SHIFT, S, exec, grim -g "$(slurp -w 0)" ~/Pictures/Screenshots/$(date +'%Y-%m-%d-%H%M%S_grim.png')''
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
        "$mainMod, Z, movewindow"
        "$mainMod, X, resizewindow"
      ];

      binde = [
        # Audio controls
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"

        # Brightness controls
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # Dynamic monitor configuration
      monitor = osConfig.mySystem.monitors;
    };
  };

  # Hyprland-related packages
  home.packages = with pkgs; [
    hyprland-protocols
    hyprwayland-scanner
    hyprutils
    hyprgraphics
    hyprlang
    hyprcursor
    aquamarine
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    hyprland
    hyprpolkitagent
    waybar
  ];
}
