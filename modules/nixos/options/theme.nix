{
  config,
  lib,
  pkgs,
  ...
}:

let
  hexColor = lib.types.strMatching "^#[0-9a-fA-F]{6}$";
  presets = import ./theme-presets.nix;
in
{
  options.mySystem.theme = lib.mkOption {
    description = "Base theme palette and toolkit settings";
    type = lib.types.submodule (
      { config, ... }:
      let
        preset = presets.${config.preset};
      in
      {
        options = {
          preset = lib.mkOption {
            type = lib.types.enum (builtins.attrNames presets);
            default = "muted-rose";
            description = "Named palette preset. Individual colors can still be overridden.";
          };

          name = lib.mkOption {
            type = lib.types.str;
            default = preset.name;
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
              default = preset.colors.accent;
              description = "Primary accent color.";
            };

            accent2 = lib.mkOption {
              type = hexColor;
              default = preset.colors.accent2;
              description = "Secondary accent color.";
            };

            background = lib.mkOption {
              type = hexColor;
              default = preset.colors.background;
              description = "Deep background tone.";
            };

            surface = lib.mkOption {
              type = hexColor;
              default = preset.colors.surface;
              description = "Default surface color for panels/cards.";
            };

            surfaceAlt = lib.mkOption {
              type = hexColor;
              default = preset.colors.surfaceAlt;
              description = "Alternate surface for inputs and secondary chrome.";
            };

            text = lib.mkOption {
              type = hexColor;
              default = preset.colors.text;
              description = "Primary text color.";
            };

            muted = lib.mkOption {
              type = hexColor;
              default = preset.colors.muted;
              description = "Muted/secondary text color.";
            };

            border = lib.mkOption {
              type = hexColor;
              default = preset.colors.border;
              description = "Border and divider color.";
            };

            shadow = lib.mkOption {
              type = hexColor;
              default = preset.colors.shadow;
              description = "Shadow color used in CSS tweaks.";
            };

            activeBorder = lib.mkOption {
              type = hexColor;
              default = config.colors.accent;
              description = "Hyprland active window border color. Defaults to accent.";
            };

            inactiveBorder = lib.mkOption {
              type = hexColor;
              default = config.colors.surface;
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

            translucent = lib.mkOption {
              type = lib.types.float;
              default = 0.85;
              description = "Window opacity applied to translucentApps.";
            };

            translucentApps = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [
                "kitty"
                "thunar"
                "gedit"
              ];
              description = "Window classes that get the translucent opacity rule.";
            };
          };

          blur = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable Hyprland background blur.";
            };

            size = lib.mkOption {
              type = lib.types.int;
              default = 5;
              description = "Blur kernel size.";
            };

            passes = lib.mkOption {
              type = lib.types.int;
              default = 2;
              description = "Number of blur passes.";
            };

            xray = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Blur straight to the wallpaper instead of windows below.";
            };
          };

          shadow = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable Hyprland window shadows.";
            };
          };

          animations = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable Hyprland animations.";
            };

            speed = lib.mkOption {
              type = lib.types.float;
              default = 2.0;
              description = "Base animation speed (Hyprland deciseconds).";
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
              default = config.colors.accent2;
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
                default = "adw-gtk3-dark";
                description = "GTK theme name to apply.";
              };

              package = lib.mkOption {
                type = lib.types.nullOr lib.types.package;
                default = pkgs.adw-gtk3;
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
            style = lib.mkOption {
              type = lib.types.str;
              default = "Fusion";
              description = "Qt widget style. Fusion respects the palette generated from the theme colors.";
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
      }
    );

    default = { };
  };
}
