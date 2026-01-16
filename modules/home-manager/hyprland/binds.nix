{ ... }:
{
  bind = [
    # === Application Launchers ===
    "$mainMod, T, exec, $terminal"
    "$mainMod, E, exec, thunar"
    "$mainMod, A, exec, caelestia-shell ipc --any-display call drawers toggle launcher"
    "$mainMod, D, exec, vesktop"
    "$mainMod, B, exec, $browser"
    "$mainMod, C, exec, code"

    # === Window Management ===
    "$mainMod, Q, killactive,"
    "$mainMod, W, togglefloating"
    "$mainMod, F, fullscreen, 0"
    "$mainMod SHIFT, F, fullscreen, 1"
    "$mainMod, P, pseudo"
    "$mainMod, J, togglesplit"
    "$mainMod, M, exit,"
    "$mainMod, G, togglegroup"
    "$mainMod, Tab, changegroupactive, f"
    "$mainMod SHIFT, Tab, changegroupactive, b"

    # === Wallpaper ===
    "$mainMod SHIFT, W, exec, wallpaper-manager"

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
    "$mainMod, mouse_down, workspace, e+1"
    "$mainMod, mouse_up, workspace, e-1"

    # === Special Workspace ===
    "$mainMod, grave, togglespecialworkspace, magic"
    "$mainMod SHIFT, grave, movetoworkspace, special:magic"

    # === Screenshots ===
    ''$mainMod, S, exec, grim -g "$(slurp -w 0)" - | wl-copy''
    ''$mainMod SHIFT, S, exec, grim -g "$(slurp -w 0)" "$HOME/Pictures/Screenshots/$(date +'%Y-%m-%d-%H%M%S_grim.png')"''
    ''$mainMod CTRL, S, exec, grim - | wl-copy''
    ''$mainMod ALT, S, exec, grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | wl-copy''

    # === Clipboard ===
    "$mainMod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
    
    # === Color Picker ===
    "$mainMod SHIFT, C, exec, hyprpicker -a"
    
    # === Screen Recording ===
    "$mainMod SHIFT, R, exec, pkill -x gpu-screen-recorder || gpu-screen-recorder -w DP-3 -f 60 -a default_output -o $HOME/Videos/$(date +'%Y-%m-%d-%H%M%S').mp4"

    # === Monitor focus ===
    "$mainMod, period, focusmonitor, -1"
    "$mainMod, comma, focusmonitor, +1"
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
}
