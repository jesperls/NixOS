{ pkgs, ... }:

{
  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/91-usb-audio.rules" ''
      # 91- runs after 90-pipewire-alsa.rules, which omits A50 Gen 5
      ACTION=="add|change", SUBSYSTEM=="pci", ATTR{class}=="0x0c0330", ATTR{power/control}="on"
      ACTION=="add|change", SUBSYSTEM=="usb", KERNEL=="usb[0-9]*", ATTR{power/control}="on"
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="1235", ATTR{power/control}="on"
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="0b1c", ATTR{power/control}="on"
      SUBSYSTEM=="sound", ACTION=="add|change", KERNEL=="card*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0b1c", ENV{ACP_PROFILE_SET}="usb-gaming-headset.conf"
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
          { "device.name" = "~alsa_card\\.usb-Logitech_A50.*"; }
        ];
        actions."update-props" = {
          "device.profile-set" = "usb-gaming-headset.conf";
          "device.profile" = "output:stereo-game+output:stereo-chat+input:mono-chat";
        };
      }
      {
        matches = [
          { "node.name" = "~alsa_(input|output)\\.usb-Focusrite_Scarlett_2i2_4th_Gen.*"; }
          { "alsa.long_card_name" = "~Focusrite Scarlett 2i2 4th Gen.*"; } # catches UCM SplitPCM's internal alsa_input.hw_Gen_0 node
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
      {
        matches = [
          { "node.name" = "alsa_output.usb-Logitech_A50-00.stereo-game"; }
        ];
        actions."update-props" = {
          "node.description" = "A50 Game";
          "node.nick" = "A50 Game";
          "priority.driver" = 1109; # alsa.lua penalizes PCM dev=1 to 828, below stereo-chat (1100)
          "priority.session" = 1109;
        };
      }
      {
        matches = [
          { "node.name" = "alsa_output.usb-Logitech_A50-00.stereo-chat"; }
        ];
        actions."update-props" = {
          "node.description" = "A50 Chat";
          "node.nick" = "A50 Chat";
          "priority.driver" = 1050;
          "priority.session" = 1050;
        };
      }
      {
        matches = [
          { "node.name" = "alsa_input.usb-Logitech_A50-00.mono-chat"; }
        ];
        actions."update-props" = {
          "node.description" = "A50 Mic";
          "node.nick" = "A50 Mic";
        };
      }
      {
        matches = [
          { "node.name" = "~alsa_input\\..*Focusrite_Scarlett.*HiFi__Line2__source"; }
        ];
        actions."update-props" = {
          "priority.session" = 1600;
        };
      }
      {
        matches = [
          { "node.name" = "~alsa_input\\.usb-Insta360.*"; }
        ];
        actions."update-props" = {
          "priority.session" = 1500;
        };
      }
      {
        matches = [
          { "node.name" = "~alsa_output\\.pci-.*\\.hdmi-.*"; }
        ];
        actions."update-props" = {
          "priority.session" = 500;
        };
      }
    ];
  };
}
