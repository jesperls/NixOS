{ ... }:

{
  services.pipewire.wireplumber.extraConfig."51-usb-audio" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "~alsa_(input|output)\\.usb-Focusrite_Scarlett_2i2_4th_Gen.*"; }
        ];
        actions."update-props" = {
          "session.suspend-timeout-seconds" = 0;
          "api.alsa.headroom" = 512;
        };
      }
      {
        matches = [
          { "node.name" = "~alsa_(input|output)\\.usb-Logitech_A50.*"; }
        ];
        actions."update-props" = {
          "session.suspend-timeout-seconds" = 0;
        };
      }
      {
        matches = [
          { "node.name" = "~alsa_output\\.usb-Logitech_A50.*"; }
        ];
        actions."update-props" = {
          "api.alsa.disable-batch" = true;
        };
      }
    ];
  };
}
