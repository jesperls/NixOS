{ config, lib, pkgs, ... }:

{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # PipeWire configuration
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;

    extraConfig.pipewire."99-hybrid-voice" = {
      "context.modules" = [{
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "Hybrid Voice";
          "capture.props" = {
            "node.name" = "hybrid_voice_input";
            "media.class" = "Audio/Sink";
            "audio.position" = [ "MONO" ];
          };
          "playback.props" = {
            "node.name" = "hybrid_voice_output";
            "media.class" = "Audio/Source";
            "audio.position" = [ "MONO" ];
          };
        };
      }];
    };
  };

  environment.etc."wireplumber/wireplumber.conf.d/51-rename-devices.conf".text =
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

  systemd.user.services.audio-auto-switch = {
    description = "Audio Auto Switcher Service";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = let
        pythonScript = pkgs.writers.writePython3 "audio-monitor" {
          libraries = [ pkgs.python3Packages.numpy ];
          flakeIgnore = [ "E501" ];
        } (builtins.readFile ./audio-monitor.py);
      in "${pythonScript}";
      Restart = "always";
      RestartSec = "5";
      Environment = "PATH=${lib.makeBinPath [ pkgs.pulseaudio pkgs.pipewire ]}";
    };
  };
}
