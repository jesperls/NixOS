{
  pkgs,
  ...
}:

let
  # Vesktop with optimized flags for better screen sharing on Wayland
  # Based on: https://github.com/Vencord/Vesktop/issues/629
  vesktop-optimized = pkgs.vesktop.overrideAttrs (oldAttrs: {
    postFixup = (oldAttrs.postFixup or "") + ''
      wrapProgram $out/bin/vesktop \
        --add-flags "--ozone-platform-hint=auto" \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--enable-webrtc-pipewire-capturer" \
        --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer,VaapiVideoDecodeLinuxGL,VaapiVideoEncoder" \
        --add-flags "--use-gl=angle" \
        --add-flags "--use-angle=gl" \
        --add-flags "--enable-wayland-ime"
    '';
  });
in
{
  home.packages = [
    vesktop-optimized
  ];
}
