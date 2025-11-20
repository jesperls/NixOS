{ config, pkgs, osConfig, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [
        "waybar"
        "systemctl --user start swww"
        "solaar -w hide"
        "systemctl --user start hyprpolkitagent"
      ];

      "$terminal" = "kitty";
      "$browser" = "firefox";
      "$mainMod" = "SUPER";

      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 0;
        "col.active_border" = "rgba(cdd6f4ee) rgba(b4befeaa) 45deg";
        "col.inactive_border" = "rgba(585b70aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 0;
        # blur = {
        #   enabled = true;
        #   size = 3;
        #   passes = 1;
        # };
        # shadow = {
        #   enabled = true;
        #   range = 4;
        #   render_power = 3;
        # };
      };

      input = {
        kb_layout = "se";
        follow_mouse = 1;
        touchpad = { natural_scroll = true; };
      };

      cursor = { no_hardware_cursors = true; };

      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, E, exec, thunar"
        "$mainMod, A, exec, wofi --show drun"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, D, exec, vesktop"
        "$mainMod, B, exec, $browser"
        "$mainMod, L, exec, hyprlock"
        "$mainMod, W, togglefloating"

        # Wallpaper controls
        "$mainMod SHIFT, W, exec, wallpaper-switcher"
        "$mainMod SHIFT, R, exec, wallpaper-manager random"

        # Fullscreen toggle
        "SHIFT, F11, fullscreen"

        # Focus movement
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Screenshots
        ''$mainMod, p, exec, grim -g "$(slurp -w 0)" - | wl-copy''
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
    hyprland
    hyprlock
    hyprpolkitagent
    waybar
  ];
}
