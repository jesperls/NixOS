{ config, pkgs, osConfig, lib, ... }:

let
  wallpaperManager = pkgs.writeShellApplication {
    name = "wallpaper-manager";
    runtimeInputs = with pkgs; [ swww hyprland jq findutils coreutils gnused ];
    text = ''
      set -euo pipefail

      default_dir="$XDG_PICTURES_DIR"
      [ -n "$default_dir" ] || default_dir="$HOME/Pictures"
      default_dir="$default_dir/Wallpapers"

      cmd="$1"
      [ -n "$cmd" ] || cmd="random"
      ensure_daemon() {
        if ! swww query >/dev/null 2>&1; then
          swww-daemon --format xrgb >/dev/null 2>&1 || swww-daemon --format rgb >/dev/null 2>&1
        fi
      }

      pick_wall() {
        local output="$1"; shift
        local dir="$1"; shift
        if [ ! -d "$dir" ]; then
          return 1
        fi
        local file
        file=$(find -L "$dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' \) | shuf -n 1)
        [ -n "$file" ] || return 1
        echo "$output -> $file" >&2
        swww img -o "$output" "$file" --transition-type grow --transition-duration 0.7 --transition-fps 60
      }

      if [ "$cmd" = "set" ]; then
        output="$2"
        file="$3"
        if [ -z "$output" ] || [ -z "$file" ]; then
          echo "usage: wallpaper-manager set <output> <file>" >&2
          exit 1
        fi
        ensure_daemon
        swww img -o "$output" "$file" --transition-type grow --transition-duration 0.7 --transition-fps 60
        exit 0
      fi

      # default: random per connected output
      ensure_daemon
      outputs=$(hyprctl monitors -j | jq -r '.[].name')
      for out in $outputs; do
        # prefer per-output directory, fallback to shared
        pick_wall "$out" "$default_dir/$out" || pick_wall "$out" "$default_dir" || echo "no wallpapers for $out" >&2
      done
    '';
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = lib.mkMerge [
      (import ./hyprland/variables.nix { })
      (import ./hyprland/settings.nix { inherit config pkgs lib osConfig; })
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
