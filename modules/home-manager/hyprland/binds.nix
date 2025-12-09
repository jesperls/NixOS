{ ... }: {
  bind = [
    "$mainMod, T, exec, $terminal"
    "$mainMod, E, exec, thunar"
    "$mainMod, A, exec, caelestia-shell ipc --any-display call drawers toggle launcher"
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
}
