{
  bind = [
    # === Application Launchers ===
    "$mainMod, T, exec, $terminal"
    "$mainMod, E, exec, thunar"
    "$mainMod, D, exec, vesktop"
    "$mainMod, B, exec, $browser"
    "$mainMod, C, exec, code"

    "$mainMod, P, exec, qs-pkg-manager"
    "$mainMod SHIFT, W, exec, wallpaper-manager pick"

    # === Window Management ===
    "$mainMod, Q, killactive,"
    "$mainMod, W, togglefloating"
    "$mainMod, F, fullscreen, 0"
    "$mainMod SHIFT, F, fullscreen, 1"
    "$mainMod, J, layoutmsg, togglesplit"
    "$mainMod, M, exec, easyeffects,"
    #"$mainMod, G, exec, myna"
    #"$mainMod, Tab, hyprexpo:expo, toggle"
    "ALT, Tab, focuscurrentorlast"
    "ALT, Tab, bringactivetotop"

    # === Focus Movement ===
    "$mainMod, left, movefocus, l"
    "$mainMod, right, movefocus, r"
    "$mainMod, up, movefocus, u"
    "$mainMod, down, movefocus, d"

    # === Window Movement ===
    "$mainMod SHIFT, left, movewindow, l"
    "$mainMod SHIFT, right, movewindow, r"
    "$mainMod SHIFT, up, movewindow, u"
    "$mainMod SHIFT, down, movewindow, d"

    # === Workspace Navigation ===
    "$mainMod, 1, workspace, 1"
    "$mainMod, 2, workspace, 2"
    "$mainMod, 3, workspace, 3"
    "$mainMod, 4, workspace, 4"
    "$mainMod, 5, workspace, 5"
    "$mainMod, 6, workspace, 6"
    "$mainMod, 7, workspace, 7"
    "$mainMod, 8, workspace, 8"
    "$mainMod, 9, workspace, 9"
    "$mainMod, 0, workspace, 10"

    # === Move to Workspace ===
    "$mainMod SHIFT, 1, movetoworkspace, 1"
    "$mainMod SHIFT, 2, movetoworkspace, 2"
    "$mainMod SHIFT, 3, movetoworkspace, 3"
    "$mainMod SHIFT, 4, movetoworkspace, 4"
    "$mainMod SHIFT, 5, movetoworkspace, 5"
    "$mainMod SHIFT, 6, movetoworkspace, 6"
    "$mainMod SHIFT, 7, movetoworkspace, 7"
    "$mainMod SHIFT, 8, movetoworkspace, 8"
    "$mainMod SHIFT, 9, movetoworkspace, 9"
    "$mainMod SHIFT, 0, movetoworkspace, 10"

    # === Workspace Scroll ===
    "$mainMod, mouse_down, workspace, r+1"
    "$mainMod, mouse_up, workspace, r-1"

    # === Special Workspace ===
    "$mainMod, grave, togglespecialworkspace, magic"
    "$mainMod SHIFT, grave, movetoworkspace, special:magic"

    # === Scratchpad  ===
    "$mainMod, S, togglespecialworkspace, scratchpad"
    "$mainMod SHIFT, S, movetoworkspace, special:scratchpad"
    "$mainMod CTRL, S, exec, [workspace special:scratchpad silent] $terminal"

    # === Clipboard ===
    "$mainMod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

    # === Screenshots & Recording ===
    "$mainMod SHIFT, Print, exec, grim - | wl-copy && notify-send 'Screenshot Taken' 'Full screen copied to clipboard' -i video-display"
    ",Print, exec, grim -g \"$(slurp)\" - | wl-copy && notify-send 'Screenshot Taken' 'Area copied to clipboard' -i video-display"

    # === Color Picker ===
    "$mainMod SHIFT, C, exec, hyprpicker -a"

    # === Monitor focus ===
    "$mainMod, period, workspace, r+1"
    "$mainMod, comma, workspace, r-1"
    "$mainMod CTRL, period, focusmonitor, -1"
    "$mainMod CTRL, comma, focusmonitor, +1"
    "$mainMod SHIFT, period, movewindow, mon:-1"
    "$mainMod SHIFT, comma, movewindow, mon:+1"
  ];

  bindm = [
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
    "$mainMod, Z, movewindow"
    "$mainMod, X, resizewindow"
  ];

  binde = [
    # === Audio Controls ===
    ", XF86AudioRaiseVolume, exec, pamixer -i 5"
    ", XF86AudioLowerVolume, exec, pamixer -d 5"
    ", XF86AudioMute, exec, pamixer -t"
    ", XF86AudioMicMute, exec, pamixer --default-source -t"

    # === Brightness Controls ===
    ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
    ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

    # === Window Resize ===
    "$mainMod CTRL, right, resizeactive, 30 0"
    "$mainMod CTRL, left, resizeactive, -30 0"
    "$mainMod CTRL, up, resizeactive, 0 -30"
    "$mainMod CTRL, down, resizeactive, 0 30"
    "$mainMod CTRL, l, resizeactive, 30 0"
    "$mainMod CTRL, h, resizeactive, -30 0"
    "$mainMod CTRL, k, resizeactive, 0 -30"
    "$mainMod CTRL, j, resizeactive, 0 30"
  ];

  bindl = [
    # === Media Controls ===
    ", XF86AudioPlay, exec, playerctl play-pause"
    ", XF86AudioPause, exec, playerctl play-pause"
    ", XF86AudioNext, exec, playerctl next"
    ", XF86AudioPrev, exec, playerctl previous"
    ", XF86AudioStop, exec, playerctl stop"
  ];

  bindr = [
    "$mainMod, Super_L, exec, caelestia-shell ipc --any-display call drawers toggle launcher"
  ];
}
