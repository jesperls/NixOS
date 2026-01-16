{ ... }:
{
  windowrulev2 = [
    # === Floating Windows ===
    "float,class:^(pavucontrol)$"
    "float,class:^(blueman-manager)$"
    "float,class:^(nm-connection-editor)$"
    "float,class:^(org.gnome.Calculator)$"
    "float,class:^(org.gnome.NautilusPreviewer)$"
    "float,class:^(eog)$"
    "float,class:^(vlc)$"
    "float,class:^(imv)$"
    "float,class:^(feh)$"
    "float,class:^(file-roller)$"
    "float,class:^(qpwgraph)$"
    "float,class:^(org.pulseaudio.pavucontrol)$"
    "float,class:^(solaar)$"
    "float,class:^(overskride)$"
    "float,class:^(scrcpy)$"
    "float,title:^(Open File)$"
    "float,title:^(Save File)$"
    "float,title:^(Confirm to replace files)$"
    "float,title:^(File Operation Progress)$"
    
    "float,title:^(Picture-in-Picture)$"
    "pin,title:^(Picture-in-Picture)$"
    "keepaspectratio,title:^(Picture-in-Picture)$"
    "size 480 270,title:^(Picture-in-Picture)$"
    "move 100%-490 100%-280,title:^(Picture-in-Picture)$"

    "opacity 0.92 0.88,class:^(kitty)$"
    
    
    "float,class:^(xdg-desktop-portal-gtk)$"
    "float,class:^(polkit-gnome-authentication-agent-1)$"
    "stayfocused,class:^(polkit-gnome-authentication-agent-1)$"
    
    "opacity 1.0 override 1.0 override,title:^(.*)(Sharing your screen)(.*)$"
    "opacity 1.0 override 1.0 override,title:^(.*)(sharing indicator)(.*)$"
    
    "float,class:^(thunar)$,title:^(File Operation Progress)$"
    "float,class:^(thunar)$,title:^(Confirm to replace files)$"
  ];
}
