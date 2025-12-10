{ lib, pkgs, ... }:

with lib;

let hexColor = types.strMatching "^#[0-9a-fA-F]{6}$";
in {
  options.mySystem.theme = mkOption {
    description = "Base theme palette and toolkit settings";
    type = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          default = "Obsidian Mocha";
          description = "Human-friendly theme name.";
        };

        borders = mkOption {
          type = types.int;
          default = 3;
          description =
            "Window border thickness in Hyprland and related tooling.";
        };

        rounding = mkOption {
          type = types.int;
          default = 10;
          description =
            "Corner radius to use for window decorations and controls.";
        };

        gaps = {
          inner = mkOption {
            type = types.int;
            default = 8;
            description = "Inner gaps between tiled windows (pixels).";
          };

          outer = mkOption {
            type = types.int;
            default = 8;
            description = "Outer gaps to screen edges (pixels).";
          };
        };

        colors = {
          accent = mkOption {
            type = hexColor;
            default = "#d47fa6";
            description = "Primary accent color (muted rose).";
          };

          accent2 = mkOption {
            type = hexColor;
            default = "#e3b17a";
            description = "Secondary accent color (warm amber).";
          };

          background = mkOption {
            type = hexColor;
            default = "#0f1117";
            description = "Deep background tone.";
          };

          surface = mkOption {
            type = hexColor;
            default = "#191b21";
            description = "Default surface color for panels/cards.";
          };

          surfaceAlt = mkOption {
            type = hexColor;
            default = "#13141a";
            description = "Alternate surface for inputs and secondary chrome.";
          };

          text = mkOption {
            type = hexColor;
            default = "#e6e3e8";
            description = "Primary text color.";
          };

          muted = mkOption {
            type = hexColor;
            default = "#b3adb9";
            description = "Muted/secondary text color.";
          };

          border = mkOption {
            type = hexColor;
            default = "#2a2d36";
            description = "Border and divider color.";
          };

          shadow = mkOption {
            type = hexColor;
            default = "#08090d";
            description = "Shadow color used in CSS tweaks.";
          };
        };

        gtk = {
          theme = {
            name = mkOption {
              type = types.str;
              default = "Adwaita-dark";
              description = "GTK theme name to apply.";
            };

            package = mkOption {
              type = types.nullOr types.package;
              default = null;
              description =
                "GTK theme package providing the theme name (null uses built-in).";
            };
          };

          iconTheme = {
            name = mkOption {
              type = types.str;
              default = "Papirus-Dark";
              description = "Icon theme name.";
            };

            package = mkOption {
              type = types.package;
              default = pkgs.papirus-icon-theme;
              description = "Icon theme package.";
            };
          };

          cursorTheme = {
            name = mkOption {
              type = types.str;
              default = "Bibata-Modern-Classic";
              description = "Cursor theme name.";
            };

            package = mkOption {
              type = types.package;
              default = pkgs.bibata-cursors;
              description = "Cursor theme package.";
            };

            size = mkOption {
              type = types.int;
              default = 24;
              description = "Cursor size in pixels.";
            };
          };
        };

        qt = {
          styleName = mkOption {
            type = types.str;
            default = "adwaita-dark";
            description = "Qt style to request via QT_STYLE_OVERRIDE.";
          };

          stylePackage = mkOption {
            type = types.package;
            default = pkgs.adwaita-qt;
            description = "Qt style package providing the style.";
          };

          platform = mkOption {
            type = types.submodule {
              options = {
                name = mkOption {
                  type = types.str;
                  default = "gtk";
                  description = "Qt platform theme name, e.g., gtk or qtct.";
                };

                package = mkOption {
                  type = types.nullOr types.package;
                  default = null;
                  description =
                    "Optional package providing the platform theme.";
                };
              };
            };
            description = "Qt platform theme configuration.";
          };
        };
      };
    };

    default = { };
  };
}
