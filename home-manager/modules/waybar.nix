{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 0;
        margin-top = 0;
        margin-left = 0;
        margin-right = 0;
        
        modules-left = [ 
          "custom/launcher"
          "hyprland/workspaces"
          "hyprland/window"
        ];
        
        modules-center = [ 
          "clock" 
        ];
        
        modules-right = [ 
          "tray"
          "bluetooth"
          "network"
          "pulseaudio"
          "battery"
          "custom/power"
        ];

        # Module configurations
        "custom/launcher" = {
          format = " ";
          on-click = "wofi --show drun";
          tooltip-format = "Applications";
        };

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "󰲠";
            "2" = "󰲢";
            "3" = "󰲤";
            "4" = "󰲦";
            "5" = "󰲨";
            "6" = "󰲪";
            "7" = "󰲬";
            "8" = "󰲮";
            "9" = "󰲰";
            "10" = "󰿬";
            "default" = "󰊠";
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
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };

        tray = {
          icon-size = 18;
          spacing = 10;
        };

        bluetooth = {
          format = "󰂯";
          format-connected = "󰂱 {num_connections}";
          format-disabled = "󰂲";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "blueman-manager";
        };

        network = {
          format-wifi = "󰤨";
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%) 󰤨";
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
            headphone = "󰋋";
            hands-free = "󰋎";
            headset = "󰋎";
            phone = "";
            portable = "";
            car = "";
            default = ["󰕿" "󰖀" "󰕾"];
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
          format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          tooltip-format = "{timeTo}";
        };

        "custom/power" = {
          format = "󰐥";
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
        font-weight: normal;
      }

      window#waybar {
        background: rgba(17, 17, 27, 0.95);
        border-radius: 0px;
        color: #bac2de;
        transition-property: background-color;
        transition-duration: 0.3s;
        margin: 0;
        padding: 0;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      #workspaces {
        background: transparent;
        margin: 3px 3px 3px 6px;
        padding: 0px 3px;
        border-radius: 4px;
        border: solid 0px transparent;
        font-weight: normal;
        font-style: normal;
      }

      #workspaces button {
        padding: 0px 6px;
        margin: 2px 1px;
        border-radius: 3px;
        border: solid 0px transparent;
        color: #6c7086;
        background: rgba(49, 50, 68, 0.3);
        transition: all 0.2s ease-in-out;
      }

      #workspaces button.active {
        color: #cdd6f4;
        background: rgba(116, 199, 236, 0.2);
        border-radius: 3px;
        min-width: 28px;
        transition: all 0.2s ease-in-out;
      }

      #workspaces button:hover {
        color: #cdd6f4;
        background: rgba(116, 199, 236, 0.1);
        border-radius: 3px;
        min-width: 28px;
        transition: all 0.2s ease-in-out;
      }

      #custom-launcher,
      #window,
      #clock,
      #battery,
      #pulseaudio,
      #network,
      #bluetooth,
      #tray,
      #custom-power {
        background: rgba(49, 50, 68, 0.4);
        margin: 3px 1px 3px 1px;
        padding: 4px 8px;
        border-radius: 4px;
        border: solid 0px transparent;
      }

      #custom-launcher {
        color: #89b4fa;
        background: rgba(49, 50, 68, 0.4);
        border-radius: 4px;
        margin: 3px 1px 3px 6px;
        padding: 4px 10px;
        font-size: 14px;
      }

      #custom-launcher:hover {
        background: rgba(137, 180, 250, 0.2);
      }

      #window {
        color: #bac2de;
        background: rgba(49, 50, 68, 0.4);
        border-radius: 4px;
        margin: 3px 1px 3px 1px;
        padding: 4px 10px;
      }

      #clock {
        color: #fab387;
        background: rgba(49, 50, 68, 0.4);
        border-radius: 4px;
        margin: 3px 1px 3px 1px;
        padding: 4px 10px;
        font-weight: normal;
      }

      #network {
        color: #a6adc8;
        background: rgba(49, 50, 68, 0.4);
        border-radius: 4px;
        margin: 3px 1px 3px 1px;
        padding: 4px 8px;
      }

      #bluetooth {
        color: #89b4fa;
        background: rgba(49, 50, 68, 0.4);
        border-radius: 4px;
        margin: 3px 1px 3px 1px;
        padding: 4px 8px;
      }

      #pulseaudio {
        color: #89dceb;
        background: rgba(49, 50, 68, 0.4);
        border-radius: 4px;
        margin: 3px 1px 3px 1px;
        padding: 4px 8px;
      }

      #battery {
        color: #a6e3a1;
        background: rgba(49, 50, 68, 0.4);
        border-radius: 4px;
        margin: 3px 1px 3px 1px;
        padding: 4px 8px;
      }

      #battery.charging {
        color: #a6e3a1;
        background: rgba(49, 50, 68, 0.4);
      }

      #battery.warning:not(.charging) {
        color: #fab387;
        background: rgba(49, 50, 68, 0.4);
      }

      #battery.critical:not(.charging) {
        color: #f38ba8;
        background: rgba(49, 50, 68, 0.4);
        animation: blink 0.8s linear infinite alternate;
      }

      @keyframes blink {
        to {
          background-color: rgba(243, 139, 168, 0.3);
        }
      }

      #tray {
        background: rgba(49, 50, 68, 0.4);
        border-radius: 4px;
        margin: 3px 1px 3px 1px;
        padding: 4px 8px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: rgba(243, 139, 168, 0.3);
      }

      #custom-power {
        color: #f38ba8;
        background: rgba(49, 50, 68, 0.4);
        border-radius: 4px;
        margin: 3px 6px 3px 1px;
        padding: 4px 10px;
        font-size: 14px;
      }

      #custom-power:hover {
        background: rgba(243, 139, 168, 0.2);
      }

      tooltip {
        border-radius: 4px;
        background-color: rgba(17, 17, 27, 0.9);
        color: #bac2de;
        border: 1px solid rgba(116, 199, 236, 0.3);
      }

      tooltip label {
        color: #bac2de;
      }
    '';
  };
}