{ pkgs, ... }:

{
  home.packages = [
    (pkgs.vesktop.override {
      withSystemVencord = false;
    })
  ];

  # Vesktop Wayland & screen sharing flags
  # Based on: https://github.com/Vencord/Vesktop/issues/629
  xdg.desktopEntries.vesktop = {
    name = "Vesktop";
    exec = "vesktop --ozone-platform-hint=auto --enable-webrtc-pipewire-capturer --enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer,VaapiVideoDecodeLinuxGL,VaapiVideoEncoder --enable-wayland-ime %U";
    icon = "vesktop";
    comment = "Vesktop with Wayland optimizations";
    categories = [
      "Network"
      "InstantMessaging"
    ];
    terminal = false;
    mimeType = [ "x-scheme-handler/discord" ];
  };
}
