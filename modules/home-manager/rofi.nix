{ config, pkgs, osConfig, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    extraConfig = {
      modi = "drun,run,filebrowser,window";
      icon-theme = "Papirus-Dark";
      show-icons = true;
      terminal = "kitty";
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-window = " 󰕰  Window";
      display-Network = " 󰤨  Network";
      sidebar-mode = true;
    };

    theme = let inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg-col = mkLiteral "${osConfig.mySystem.theme.colors.base}";
        bg-col-light = mkLiteral "${osConfig.mySystem.theme.colors.surface}";
        border-col = mkLiteral "${osConfig.mySystem.theme.colors.surface}";
        selected-col = mkLiteral "${osConfig.mySystem.theme.colors.surface}";
        selected-highlight =
          mkLiteral "${osConfig.mySystem.theme.colors.accent}";
        blue = mkLiteral "${osConfig.mySystem.theme.colors.accent}";
        fg-col = mkLiteral "${osConfig.mySystem.theme.colors.text}";
        fg-col2 = mkLiteral "${osConfig.mySystem.theme.colors.urgent}";
        grey = mkLiteral "${osConfig.mySystem.theme.colors.subtext}";
        width = 900;
        font = "${osConfig.mySystem.theme.fonts.monospace} 15";
      };

      "element-text, element-icon , mode-switcher" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      "window" = {
        height = mkLiteral "750px";
        border = mkLiteral "${toString osConfig.mySystem.theme.borders}px";
        border-radius =
          mkLiteral "${toString osConfig.mySystem.theme.rounding}px";
        background-color = mkLiteral "@bg-col";
        padding = mkLiteral "20px";
      };

      "mainbox" = {
        background-color = mkLiteral "@bg-col";
        padding = mkLiteral "8px";
        spacing = mkLiteral "12px";
      };

      "inputbar" = {
        children = map mkLiteral [ "prompt" "entry" ];
        background-color = mkLiteral "@bg-col-light";
        border-radius =
          mkLiteral "${toString osConfig.mySystem.theme.rounding}px";
        padding = mkLiteral "12px";
        spacing = mkLiteral "12px";
      };

      "prompt" = {
        background-color = mkLiteral "@blue";
        padding = mkLiteral "10px 18px";
        text-color = mkLiteral "@bg-col";
        border-radius =
          mkLiteral "${toString osConfig.mySystem.theme.rounding}px";
        font = "${osConfig.mySystem.theme.fonts.monospace} Bold 15";
      };

      "textbox-prompt-colon" = {
        expand = false;
        str = ":";
      };

      "entry" = {
        padding = mkLiteral "10px";
        text-color = mkLiteral "@fg-col";
        background-color = mkLiteral "transparent";
        placeholder = "Search applications...";
        placeholder-color = mkLiteral "@grey";
      };

      "listview" = {
        border = mkLiteral "0";
        padding = mkLiteral "4px 0px";
        margin = mkLiteral "0px";
        columns = 1;
        lines = 10;
        background-color = mkLiteral "@bg-col";
        spacing = mkLiteral "4px";
        scrollbar = false;
      };

      "scrollbar" = {
        width = mkLiteral "3px";
        border = mkLiteral "0";
        handle-color = mkLiteral "@blue";
        handle-width = mkLiteral "3px";
        padding = mkLiteral "0";
        margin = mkLiteral "0 0 0 6px";
      };

      "element" = {
        padding = mkLiteral "10px 16px";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg-col";
        border-radius =
          mkLiteral "${toString osConfig.mySystem.theme.rounding}px";
        spacing = mkLiteral "12px";
      };

      "element-icon" = {
        size = mkLiteral "36px";
        background-color = mkLiteral "transparent";
      };

      "element-text" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };

      "element normal.normal" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg-col";
      };

      "element selected.normal" = {
        background-color = mkLiteral "@selected-col";
        text-color = mkLiteral "@selected-highlight";
        border = mkLiteral "0px 0px 2px 0px";
        border-color = mkLiteral "@blue";
      };

      "element alternate.normal" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg-col";
      };

      "mode-switcher" = {
        spacing = mkLiteral "6px";
        padding = mkLiteral "6px 0px 0px 0px";
      };

      "button" = {
        padding = mkLiteral "12px 18px";
        background-color = mkLiteral "@bg-col-light";
        text-color = mkLiteral "@grey";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.5";
        border-radius =
          mkLiteral "${toString osConfig.mySystem.theme.rounding}px";
      };

      "button selected" = {
        background-color = mkLiteral "@selected-col";
        text-color = mkLiteral "@blue";
        border = mkLiteral "0px 0px 2px 0px";
        border-color = mkLiteral "@blue";
      };

      "message" = {
        background-color = mkLiteral "@bg-col-light";
        margin = mkLiteral "6px";
        padding = mkLiteral "10px";
        border-radius =
          mkLiteral "${toString osConfig.mySystem.theme.rounding}px";
      };

      "textbox" = {
        padding = mkLiteral "10px";
        text-color = mkLiteral "@blue";
        background-color = mkLiteral "transparent";
      };
    };
  };
}
