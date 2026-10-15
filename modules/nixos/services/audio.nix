{ ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  services.pipewire.extraConfig.pipewire."99-performance" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.allowed-rates" = [
        48000
        44100
      ];
      "default.clock.quantum" = 512;
      "default.clock.min-quantum" = 256;
      "default.clock.max-quantum" = 2048;
    };
  };

  services.pipewire.extraConfig.pipewire-pulse."99-pulse-latency" = {
    "pulse.properties" = {
      "pulse.min.req" = "256/48000";
      "pulse.default.req" = "512/48000";
      "pulse.min.quantum" = "256/48000";
    };
    "pulse.rules" = [
      {
        matches = [
          { "application.name" = "~WEBRTC VoiceEngine|Chromium.*"; }
          { "media.role" = "Communication"; }
        ];
        actions.update-props = {
          "pulse.min.req" = "512/48000";
          "pulse.min.quantum" = "512/48000";
        };
      }
    ];
  };
}
