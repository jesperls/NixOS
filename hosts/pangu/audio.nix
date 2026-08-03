{ ... }:

{
  services.pipewire.wireplumber.extraConfig."51-scarlett-config" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "~alsa_(input|output)\\.usb-Focusrite_Scarlett_2i2_4th_Gen.*"; }
        ];
        actions."update-props" = {
          "session.suspend-timeout-seconds" = 0;
        };
      }
    ];
  };
}
