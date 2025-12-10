{ config, pkgs, osConfig, lib, ... }:

let
  wallpaperManager = pkgs.writeShellApplication {
    name = "wallpaper-manager";
    runtimeInputs = with pkgs; [ swww hyprland jq findutils coreutils gnused ];
    text = ''
      set -euo pipefail

      # Prefer XDG_PICTURES_DIR if set; fallback to ~/Pictures
      default_dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpapers"
      cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-manager"
      mkdir -p "$cache_dir"

      cmd="''${1:-cycle}"

      ensure_daemon() {
        if ! swww query >/dev/null 2>&1; then
          swww-daemon --format xrgb >/dev/null 2>&1 || swww-daemon --format rgb >/dev/null 2>&1
        fi
      }

      focused_output() {
        hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' | head -n1
      }

      pick_list() {
        local dir="$1"
        if [ ! -d "$dir" ]; then
          return 1
        fi
        find -L "$dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' \) | LC_COLLATE=C sort
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
        swww img -o "$output" "$file" --transition-type grow --transition-duration 0.7 --transition-fps 60
        return 0
      }

      cycle_focused() {
        ensure_daemon
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

      if [ "$cmd" = "set" ]; then
        output="''${2:-}"
        file="''${3:-}"
        if [ -z "$output" ] || [ -z "$file" ]; then
          echo "usage: wallpaper-manager set <output> <file>" >&2
          exit 1
        fi
        ensure_daemon
        swww img -o "$output" "$file" --transition-type grow --transition-duration 0.7 --transition-fps 60
        exit 0
      fi

      # default: cycle wallpapers on the focused monitor
      cycle_focused
    '';
  };
  hyprSettings =
    import ./hyprland/settings.nix { inherit config pkgs lib osConfig; };
in {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = lib.mkMerge [
      (import ./hyprland/variables.nix { })
      hyprSettings.settings
      (import ./hyprland/binds.nix { })
      (import ./hyprland/windowrules.nix { })
    ];
  };

  # Hyprland portal configuration for screensharing
  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';

  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww wallpaper daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swww}/bin/swww-daemon --format xrgb";
      Restart = "on-failure";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  # Hyprland-related user packages
  home.packages = (with pkgs; [
    # Hyprland ecosystem packages
    hyprland-protocols
    hyprwayland-scanner
    hyprutils
    hyprgraphics
    hyprlang
    hyprcursor
    aquamarine
    hyprpolkitagent

    # Desktop portals (user-level installation)
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ]) ++ [ wallpaperManager ];
}
