{ theme }: ''
  * {
    border: none;
    border-radius: 0;
    font-family: "${theme.fonts.monospace}", monospace;
    font-size: 13px;
    min-height: 0;
    font-weight: bold;
  }

  window#waybar {
    background: ${theme.colors.base};
    color: ${theme.colors.text};
    border-bottom: ${toString theme.borders}px solid ${theme.colors.surface};
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
    color: ${theme.colors.subtext};
    background: transparent;
    border-bottom: 2px solid transparent;
    transition: all 0.3s ease-in-out;
  }

  #workspaces button.active {
    color: ${theme.colors.accent};
    border-bottom: 2px solid ${theme.colors.accent};
  }

  #workspaces button:hover {
    color: ${theme.colors.accent2};
    background: rgba(180, 190, 254, 0.1);
  }

  #custom-launcher {
    color: ${theme.colors.accent};
    padding: 0 10px;
    font-size: 16px;
    margin-left: 4px;
  }

  #window {
    color: ${theme.colors.subtext};
    padding: 0 10px;
  }

  #clock {
    color: ${theme.colors.text};
    padding: 0 10px;
  }

  #cpu, #memory, #disk {
    color: ${theme.colors.warning};
    padding: 0 6px;
  }

  #network {
    color: ${theme.colors.success};
    padding: 0 6px;
  }

  #bluetooth {
    color: ${theme.colors.accent};
    padding: 0 6px;
  }

  #pulseaudio {
    color: ${theme.colors.warning};
    padding: 0 6px;
  }

  #battery {
    color: ${theme.colors.success};
    padding: 0 6px;
  }

  #battery.charging {
    color: ${theme.colors.success};
  }

  #battery.warning:not(.charging) {
    color: ${theme.colors.warning};
  }

  #battery.critical:not(.charging) {
    color: ${theme.colors.urgent};
    animation: blink 0.8s linear infinite alternate;
  }

  @keyframes blink {
    to {
      color: ${theme.colors.base};
      background-color: ${theme.colors.urgent};
    }
  }

  #tray {
    padding: 0 6px;
  }

  #custom-power {
    color: ${theme.colors.urgent};
    padding: 0 10px;
    margin-right: 4px;
  }

  tooltip {
    background-color: ${theme.colors.base};
    border: 1px solid ${theme.colors.surface};
  }

  tooltip label {
    color: ${theme.colors.text};
  }
''
