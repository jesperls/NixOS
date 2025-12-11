{ config, lib, pkgs, ... }:

with lib;

let cfg = config.mySystem.services.audio;
in {
  options.mySystem.services.audio = {
    enable = mkEnableOption "audio configuration";

    hybrid = {
      enable = mkEnableOption "hybrid audio source switching";

      preferredNode = mkOption {
        type = types.str;
        description =
          "The PulseAudio/PipeWire name of the preferred input node.";
      };

      fallbackNode = mkOption {
        type = types.str;
        description =
          "The PulseAudio/PipeWire name of the fallback input node.";
      };

      sinkName = mkOption {
        type = types.str;
        description = "The name of the hybrid voice sink.";
      };
    };
  };

  config = mkIf cfg.enable {
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
    };

    services.pipewire.extraConfig.pipewire."99-hybrid-voice" =
      mkIf cfg.hybrid.enable {
        "context.modules" = [{
          name = "libpipewire-module-loopback";
          args = {
            "node.description" = "Hybrid Voice";
            "capture.props" = {
              "node.name" = cfg.hybrid.sinkName;
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

    environment.etc."wireplumber/wireplumber.conf.d/51-rename-devices.conf" =
      mkIf cfg.hybrid.enable {
        text = ''
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
      };

    systemd.user.services.audio-auto-switch = mkIf cfg.hybrid.enable {
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
        Environment = [
          "PATH=${lib.makeBinPath [ pkgs.pulseaudio pkgs.pipewire ]}"
          "PREFERRED_NODE=${cfg.hybrid.preferredNode}"
          "FALLBACK_NODE=${cfg.hybrid.fallbackNode}"
          "SINK_NAME=${cfg.hybrid.sinkName}"
        ];
      };
    };
  };
}
