{ lib, pkgs, ... }:

with lib;

{
  options.mySystem.theme = {
    colors = {
      base = mkOption {
        type = types.str;
        default = "#1e1e2e";
      };
      surface = mkOption {
        type = types.str;
        default = "#313244";
      };
      text = mkOption {
        type = types.str;
        default = "#cdd6f4";
      };
      subtext = mkOption {
        type = types.str;
        default = "#a6adc8";
      };
      accent = mkOption {
        type = types.str;
        default = "#89b4fa";
      };
      accent2 = mkOption {
        type = types.str;
        default = "#cba6f7";
      };
      urgent = mkOption {
        type = types.str;
        default = "#f38ba8";
      };
      success = mkOption {
        type = types.str;
        default = "#a6e3a1";
      };
      warning = mkOption {
        type = types.str;
        default = "#fab387";
      };
    };
    fonts = {
      default = mkOption {
        type = types.str;
        default = "Noto Sans";
      };
      monospace = mkOption {
        type = types.str;
        default = "JetBrainsMono Nerd Font";
      };
      size = mkOption {
        type = types.int;
        default = 11;
      };
    };
    rounding = mkOption {
      type = types.int;
      default = 0;
    };
    borders = mkOption {
      type = types.int;
      default = 0;
    };
  };
}
