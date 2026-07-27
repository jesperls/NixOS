{ ... }:

{
  services.pipewire.wireplumber.extraConfig."51-a50-config" = {
    "monitor.alsa.rules" = [
      {
        matches = [ { "node.name" = "~alsa_output.usb-Logitech_A50-00.*"; } ];
        actions."update-props" = {
          "api.alsa.disable-batch" = true;
          "session.suspend-timeout-seconds" = 0;
        };
      }
      {
        matches = [ { "node.name" = "alsa_output.usb-Logitech_A50-00.pro-output-0"; } ];
        actions."update-props" = {
          "node.description" = "A50 Voice";
          "node.nick" = "A50 Voice";
        };
      }
      {
        matches = [ { "node.name" = "alsa_output.usb-Logitech_A50-00.pro-output-1"; } ];
        actions."update-props" = {
          "node.description" = "A50 Game";
          "node.nick" = "A50 Game";
        };
      }
      {
        matches = [ { "node.name" = "alsa_input.usb-Logitech_A50-00.pro-input-0"; } ];
        actions."update-props" = {
          "node.description" = "A50 Microphone";
          "node.nick" = "A50 Mic";
        };
      }
      {
        matches = [ { "node.name" = "alsa_input.usb-Logitech_A50-00.pro-input-1"; } ];
        actions."update-props" = {
          "node.description" = "A50 Monitor";
          "node.nick" = "A50 Monitor";
        };
      }
    ];
  };
}
