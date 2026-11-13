{ pkgs, ... }:

{
  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/90-usb-audio-power.rules" ''
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="1235", ATTR{power/control}="on"
    '')
  ];

  services.pipewire.wireplumber.extraConfig."51-usb-audio" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "device.name" = "~alsa_card\\.usb-(Focusrite_Scarlett|Logitech_A50).*"; }
        ];
        actions."update-props" = {
          "device.recover-on-error" = true;
        };
      }
      {
        matches = [
          { "node.name" = "~alsa_(input|output)\\.usb-Focusrite_Scarlett_2i2_4th_Gen.*"; }
          { "alsa.long_card_name" = "~Focusrite Scarlett 2i2 4th Gen.*"; } # catches UCM SplitPCM's internal alsa_input.hw_Gen_0 node
        ];
        actions."update-props" = {
          "session.suspend-timeout-seconds" = 0;
          "api.alsa.disable-batch" = true;
          "api.alsa.headroom" = 256;
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
