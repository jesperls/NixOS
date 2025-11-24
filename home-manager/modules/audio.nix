{ pkgs, ... }:

{
  xdg.configFile."wireplumber/wireplumber.conf.d/51-rename-devices.conf".text =
    ''
      monitor.alsa.rules = [
        {
          matches = [
            {
              node.name = "alsa_output.usb-Logitech_A50-00.pro-output-0"
            }
          ]
          actions = {
            update-props = {
              node.description = "A50 Pro Voice"
            }
          }
        }
        {
          matches = [
            {
              node.name = "alsa_output.usb-Logitech_A50-00.pro-output-1"
            }
          ]
          actions = {
            update-props = {
              node.description = "A50 Pro Game"
            }
          }
        }
        {
          matches = [
            {
              node.name = "alsa_input.usb-Logitech_A50-00.pro-input-0"
            }
          ]
          actions = {
            update-props = {
              node.description = "A50 Pro Main"
            }
          }
        }
        {
          matches = [
            {
              node.name = "alsa_input.usb-Logitech_A50-00.pro-input-1"
            }
          ]
          actions = {
            update-props = {
              node.description = "A50 Pro Monitor"
            }
          }
        }
      ]
    '';
}
