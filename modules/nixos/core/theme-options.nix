{ lib, pkgs, ... }:

let
  hexColor = lib.types.strMatching "^#[0-9a-fA-F]{6}$";
in
{
  options.mySystem.theme = lib.mkOption {
    description = "Base theme palette and toolkit settings";
    type = lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "Obsidian Mocha";
          description = "Human-friendly theme name.";
        };

        borders = lib.mkOption {
          type = lib.types.int;
          default = 3;
          description = "Window border thickness in Hyprland and related tooling.";
        };

        rounding = lib.mkOption {
          type = lib.types.int;
          default = 10;
          description = "Corner radius to use for window decorations and controls.";
        };

        gaps = {
          inner = lib.mkOption {
            type = lib.types.int;
            default = 8;
            description = "Inner gaps between tiled windows (pixels).";
          };

          outer = lib.mkOption {
            type = lib.types.int;
            default = 8;
            description = "Outer gaps to screen edges (pixels).";
          };
        };

        colors = {
          accent = lib.mkOption {
            type = hexColor;
            default = "#d47fa6";
            description = "Primary accent color (muted rose).";
          };

          accent2 = lib.mkOption {
            type = hexColor;
            default = "#e3b17a";
            description = "Secondary accent color (warm amber).";
          };

          background = lib.mkOption {
            type = hexColor;
            default = "#0f1117";
            description = "Deep background tone.";
          };

          surface = lib.mkOption {
            type = hexColor;
            default = "#191b21";
            description = "Default surface color for panels/cards.";
          };

          surfaceAlt = lib.mkOption {
            type = hexColor;
            default = "#13141a";
            description = "Alternate surface for inputs and secondary chrome.";
          };

          text = lib.mkOption {
            type = hexColor;
            default = "#e6e3e8";
            description = "Primary text color.";
          };

          muted = lib.mkOption {
            type = hexColor;
            default = "#b3adb9";
            description = "Muted/secondary text color.";
          };

          border = lib.mkOption {
            type = hexColor;
            default = "#2a2d36";
            description = "Border and divider color.";
          };

          shadow = lib.mkOption {
            type = hexColor;
            default = "#08090d";
            description = "Shadow color used in CSS tweaks.";
          };

          activeBorder = lib.mkOption {
            type = hexColor;
            default = "#a869a8";
            description = "Hyprland active window border color. Defaults to accent.";
          };

          inactiveBorder = lib.mkOption {
            type = hexColor;
            default = "#191b21";
            description = "Hyprland inactive window border color. Defaults to surface.";
          };
        };

        opacity = {
          activeBorder = lib.mkOption {
            type = lib.types.strMatching "^[0-9a-fA-F]{2}$";
            default = "ee";
            description = "Hex alpha for active window border (00-ff).";
          };

          inactiveBorder = lib.mkOption {
            type = lib.types.strMatching "^[0-9a-fA-F]{2}$";
            default = "aa";
            description = "Hex alpha for inactive window border (00-ff).";
          };
        };

        borderGradient = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to use a gradient for the active window border.";
          };

          secondColor = lib.mkOption {
            type = hexColor;
            default = "#e3b17a";
            description = "Second color in the border gradient. Defaults to accent2.";
          };

          angle = lib.mkOption {
            type = lib.types.int;
            default = 45;
            description = "Gradient angle in degrees.";
          };
        };

        gtk = {
          theme = {
            name = lib.mkOption {
              type = lib.types.str;
              default = "Adwaita-dark";
              description = "GTK theme name to apply.";
            };

            package = lib.mkOption {
              type = lib.types.nullOr lib.types.package;
              default = null;
              description = "GTK theme package providing the theme name (null uses built-in).";
            };
          };

          iconTheme = {
            name = lib.mkOption {
              type = lib.types.str;
              default = "Papirus-Dark";
              description = "Icon theme name.";
            };

            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.papirus-icon-theme;
              description = "Icon theme package.";
            };
          };

          cursorTheme = {
            name = lib.mkOption {
              type = lib.types.str;
              default = "Bibata-Modern-Classic";
              description = "Cursor theme name.";
            };

            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.bibata-cursors;
              description = "Cursor theme package.";
            };

            size = lib.mkOption {
              type = lib.types.int;
              default = 24;
              description = "Cursor size in pixels.";
            };
          };
        };

        qt = {
          styleName = lib.mkOption {
            type = lib.types.str;
            default = "adwaita-dark";
            description = "Qt style to request via QT_STYLE_OVERRIDE.";
          };

          stylePackage = lib.mkOption {
            type = lib.types.package;
            default = pkgs.adwaita-qt;
            description = "Qt style package providing the style.";
          };

          platform = lib.mkOption {
            type = lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  default = "gtk";
                  description = "Qt platform theme name, e.g., gtk or qtct.";
                };

                package = lib.mkOption {
                  type = lib.types.nullOr lib.types.package;
                  default = null;
                  description = "Optional package providing the platform theme.";
                };
              };
            };
            description = "Qt platform theme configuration.";
          };
        };

        fonts = {
          monospace = lib.mkOption {
            type = lib.types.str;
            default = "JetBrainsMono Nerd Font";
            description = "Monospace font for terminals and code editors.";
          };

          sans = lib.mkOption {
            type = lib.types.str;
            default = "Noto Sans";
            description = "Sans-serif font for UI elements.";
          };

          size = lib.mkOption {
            type = lib.types.int;
            default = 11;
            description = "Default font size.";
          };

          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
              noto-fonts
              noto-fonts-cjk-sans
              noto-fonts-color-emoji
              font-awesome
              nerd-fonts.jetbrains-mono
            ];
            description = "Font packages to install. Override to match your font choices.";
          };
        };
      };
    };

    default = { };
  };
}
