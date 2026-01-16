{
  config,
  pkgs,
  osConfig,
  lib,
  ...
}:

let
  wallpaperManager = pkgs.writeShellApplication {
    name = "wallpaper-manager";
    runtimeInputs = with pkgs; [
      hyprpaper
      hyprland
      jq
      findutils
      coreutils
      gnused
    ];
    text = ''
      set -euo pipefail

      # Prefer XDG_PICTURES_DIR if set; fallback to ~/Pictures
      default_dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpapers"
      cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-manager"
      mkdir -p "$cache_dir"

      cmd="''${1:-cycle}"

      focused_output() {
        hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' | head -n1
      }

      all_outputs() {
        hyprctl monitors -j | jq -r '.[].name'
      }

      pick_list() {
        local dir="$1"
        if [ ! -d "$dir" ]; then
          return 1
        fi
        find -L "$dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' \) | LC_COLLATE=C sort
      }

      set_wallpaper() {
        local output="$1"
        local file="$2"
        # Save current wallpaper path for persistence
        echo "$file" > "$cache_dir/''${output//\//_}.current"
        # Preload the wallpaper, then set it
        hyprctl hyprpaper preload "$file" 2>/dev/null || true
        hyprctl hyprpaper wallpaper "$output,$file"
        # Unload unused wallpapers to save memory
        hyprctl hyprpaper unload unused 2>/dev/null || true
      }

      next_wall_for_output() {
        local output="$1"
        local dir="$2"
        local state_file="$cache_dir/''${output//\//_}.idx"
        mapfile -t files < <(pick_list "$dir") || true
        if [ "''${#files[@]}" -eq 0 ]; then
          return 1
        fi

        local last_idx=-1
        if [ -f "$state_file" ]; then
          read -r last_idx < "$state_file" || true
        fi
        local next_idx=$(( (last_idx + 1) % ''${#files[@]} ))
        echo "$next_idx" > "$state_file"

        local file="''${files[$next_idx]}"
        echo "$output -> $file" >&2
        set_wallpaper "$output" "$file"
        return 0
      }

      restore_wallpaper() {
        local output="$1"
        local current_file="$cache_dir/''${output//\//_}.current"
        if [ -f "$current_file" ]; then
          local file
          read -r file < "$current_file" || true
          if [ -f "$file" ]; then
            echo "Restoring $output -> $file" >&2
            set_wallpaper "$output" "$file"
            return 0
          fi
        fi
        # No saved wallpaper, set first from directory
        next_wall_for_output "$output" "$default_dir/$output" || next_wall_for_output "$output" "$default_dir" || true
      }

      cycle_focused() {
        local out
        out=$(focused_output)
        if [ -z "$out" ]; then
          echo "no focused monitor detected" >&2
          exit 1
        fi

        next_wall_for_output "$out" "$default_dir/$out" || next_wall_for_output "$out" "$default_dir" || {
          echo "no wallpapers found for $out" >&2
          exit 1
        }
      }

      init_all() {
        # Wait a moment for hyprpaper to be ready
        sleep 0.5
        for output in $(all_outputs); do
          restore_wallpaper "$output"
        done
      }

      case "$cmd" in
        set)
          output="''${2:-}"
          file="''${3:-}"
          if [ -z "$output" ] || [ -z "$file" ]; then
            echo "usage: wallpaper-manager set <output> <file>" >&2
            exit 1
          fi
          set_wallpaper "$output" "$file"
          ;;
        init)
          init_all
          ;;
        *)
          # default: cycle wallpapers on the focused monitor
          cycle_focused
          ;;
      esac
    '';
  };
  hyprSettings = import ./hyprland/settings.nix {
    inherit
      config
      pkgs
      lib
      osConfig
      ;
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = lib.mkMerge [
      (import ./hyprland/variables.nix { })
      hyprSettings.settings
      (import ./hyprland/binds.nix { })
      (import ./hyprland/windowrules.nix { })
    ];
  };

  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
    };
  };

  home.packages =
    (with pkgs; [
      hyprland-protocols
      hyprwayland-scanner
      hyprutils
      hyprgraphics
      hyprlang
      hyprcursor
      aquamarine
      hyprpolkitagent
      hyprpicker

      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ])
    ++ [ wallpaperManager ];
}
