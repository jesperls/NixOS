{ }: {
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
      tooltip-format-enumerate-connected = "{device_alias}	{device_address}";
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
}
