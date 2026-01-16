{ ... }:
{
  windowrule = [
    # === Floating Windows ===
    "match:class pavucontrol, float on"
    "match:class blueman-manager, float on"
    "match:class nm-connection-editor, float on"
    "match:class org.gnome.Calculator, float on"
    "match:class org.gnome.NautilusPreviewer, float on"
    "match:class eog, float on"
    "match:class vlc, float on"
    "match:class imv, float on"
    "match:class feh, float on"
    "match:class file-roller, float on"
    "match:class qpwgraph, float on"
    "match:class org.pulseaudio.pavucontrol, float on"
    "match:class solaar, float on"
    "match:class overskride, float on"
    "match:class scrcpy, float on"
    "match:title ^(Open File)$, float on"
    "match:title ^(Save File)$, float on"
    "match:title ^(Confirm to replace files)$, float on"
    "match:title ^(File Operation Progress)$, float on"

    # === Picture-in-Picture ===
    "match:title ^(Picture-in-Picture)$, float on"
    "match:title ^(Picture-in-Picture)$, pin on"
    "match:title ^(Picture-in-Picture)$, size 480 270"
    "match:title ^(Picture-in-Picture)$, move 100%-490 100%-280"

    # === Opacity ===
    "match:class kitty, opacity 0.92 0.88"

    # === Portal & Auth ===
    "match:class xdg-desktop-portal-gtk, float on"
    "match:class polkit-gnome-authentication-agent-1, float on"

    # === Screen Sharing ===
    "match:title r:Sharing your screen, opacity 1.0 override 1.0 override"
    "match:title r:sharing indicator, opacity 1.0 override 1.0 override"

    # === Thunar Dialogs ===
    "match:class thunar match:title ^(File Operation Progress)$, float on"
    "match:class thunar match:title ^(Confirm to replace files)$, float on"
  ];
}
