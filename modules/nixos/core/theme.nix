{ lib, pkgs, ... }:

with lib;

{
  options.mySystem.theme = {
    colors = {
      base = mkOption {
        type = types.str;
        default = "#1e1e2e";
        description = "Base background color";
      };
      surface = mkOption {
        type = types.str;
        default = "#313244";
        description = "Surface/secondary background color";
      };
      text = mkOption {
        type = types.str;
        default = "#cdd6f4";
        description = "Primary text color";
      };
      subtext = mkOption {
        type = types.str;
        default = "#a6adc8";
        description = "Secondary/dimmed text color";
      };
      accent = mkOption {
        type = types.str;
        default = "#89b4fa";
        description = "Primary accent color";
      };
      accent2 = mkOption {
        type = types.str;
        default = "#cba6f7";
        description = "Secondary accent color";
      };
      urgent = mkOption {
        type = types.str;
        default = "#f38ba8";
        description = "Urgent/error color";
      };
      success = mkOption {
        type = types.str;
        default = "#a6e3a1";
        description = "Success/positive color";
      };
      warning = mkOption {
        type = types.str;
        default = "#fab387";
        description = "Warning/caution color";
      };
    };

    fonts = {
      default = mkOption {
        type = types.str;
        default = "Noto Sans";
        description = "Default system font";
      };
      monospace = mkOption {
        type = types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Monospace font for terminals and code";
      };
      size = mkOption {
        type = types.int;
        default = 11;
        description = "Default font size";
      };
    };

    rounding = mkOption {
      type = types.int;
      default = 0;
      description = "Border radius for rounded corners (in pixels)";
    };

    borders = mkOption {
      type = types.int;
      default = 0;
      description = "Border width (in pixels)";
    };
  };
}
