{ ... }:

{
  services.pipewire.wireplumber.extraConfig."51-usb-audio" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "~alsa_(input|output)\\.usb-(Focusrite_Scarlett_2i2_4th_Gen|Logitech_A50).*"; }
        ];
        actions."update-props" = {
          "session.suspend-timeout-seconds" = 0;
          "api.alsa.headroom" = 512;
        };
      }
    ];
  };
}
