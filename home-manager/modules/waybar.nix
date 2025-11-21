{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        margin-top = 0;
        margin-left = 0;
        margin-right = 0;

        modules-left =
          [ "custom/launcher" "hyprland/workspaces" "hyprland/window" ];

        modules-center = [ "clock" ];

        modules-right = [
          "cpu"
          "memory"
          "disk"
          "tray"
          "bluetooth"
          "network"
          "pulseaudio"
          "battery"
          "custom/power"
        ];

        # Module configurations
        "custom/launcher" = {
          format = "";
          on-click = "rofi -show drun";
          tooltip-format = "NixOS";
        };

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            "default" = "";
          };
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 50;
          separate-outputs = true;
        };

        clock = {
          interval = 1;
          format = "{:%H:%M}";
          format-alt = "{:%A, %B %d, %Y (%R)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#cba6f7'><b>{}</b></span>";
              days = "<span color='#cdd6f4'><b>{}</b></span>";
              weeks = "<span color='#94e2d5'><b>W{}</b></span>";
              weekdays = "<span color='#f9e2af'><b>{}</b></span>";
              today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
            };
          };
        };

        cpu = {
          interval = 5;
          format = " {usage}%";
          tooltip = true;
        };

        memory = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };

        disk = {
          interval = 30;
          format = " {percentage_used}%";
          path = "/";
        };

        tray = {
          icon-size = 18;
          spacing = 10;
        };

        bluetooth = {
          format = "";
          format-connected = " {num_connections}";
          format-disabled = "󰂲";
          tooltip-format = "{controller_alias}	{controller_address}";
          tooltip-format-connected = ''
            {controller_alias}\t{controller_address}

            {device_enumerate}'';
          tooltip-format-enumerate-connected =
            "{device_alias}	{device_address}";
          on-click = "blueman-manager";
        };

        network = {
          format-wifi = "";
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ifname}";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
          on-click = "nm-connection-editor";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pamixer -t";
          on-click-right = "pavucontrol";
          scroll-step = 5;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = [ "" "" "" "" "" ];
          tooltip-format = "{timeTo}";
        };

        "custom/power" = {
          format = "";
          tooltip-format = "Power Menu";
          on-click = "wlogout";
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", "Fira Code Nerd Font", monospace;
        font-size: 13px;
        min-height: 0;
        font-weight: bold;
      }

      window#waybar {
        background: #1e1e2e; /* Catppuccin Mocha Base */
        color: #cdd6f4; /* Text */
        border-bottom: 1px solid #313244;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      #workspaces {
        background: transparent;
        margin: 0 4px;
      }

      #workspaces button {
        padding: 0 5px;
        color: #6c7086; /* Overlay0 */
        background: transparent;
        border-bottom: 2px solid transparent;
        transition: all 0.3s ease-in-out;
      }

      #workspaces button.active {
        color: #89b4fa; /* Blue */
        border-bottom: 2px solid #89b4fa;
      }

      #workspaces button:hover {
        color: #b4befe; /* Lavender */
        background: rgba(180, 190, 254, 0.1);
      }

      #custom-launcher {
        color: #89b4fa; /* Blue */
        padding: 0 10px;
        font-size: 16px;
        margin-left: 4px;
      }

      #window {
        color: #a6adc8; /* Subtext0 */
        padding: 0 10px;
      }

      #clock {
        color: #cdd6f4; /* Text */
        padding: 0 10px;
      }

      #cpu, #memory, #disk {
        color: #fab387; /* Peach */
        padding: 0 6px;
      }

      #network {
        color: #94e2d5; /* Teal */
        padding: 0 6px;
      }

      #bluetooth {
        color: #89b4fa; /* Blue */
        padding: 0 6px;
      }

      #pulseaudio {
        color: #f9e2af; /* Yellow */
        padding: 0 6px;
      }

      #battery {
        color: #a6e3a1; /* Green */
        padding: 0 6px;
      }

      #battery.charging {
        color: #a6e3a1;
      }

      #battery.warning:not(.charging) {
        color: #fab387;
      }

      #battery.critical:not(.charging) {
        color: #f38ba8;
        animation: blink 0.8s linear infinite alternate;
      }

      @keyframes blink {
        to {
          color: #1e1e2e;
          background-color: #f38ba8;
        }
      }

      #tray {
        padding: 0 6px;
      }

      #custom-power {
        color: #f38ba8; /* Red */
        padding: 0 10px;
        margin-right: 4px;
      }

      tooltip {
        background-color: #1e1e2e;
        border: 1px solid #313244;
      }

      tooltip label {
        color: #cdd6f4;
      }
    '';
  };
}
