{ config, pkgs, swww, ... }:

let
  userConfig = import ../../user.nix;
  system = pkgs.stdenv.hostPlatform.system;

  # Create wallpaper switching script
  wallpaperSwitcher = pkgs.writeShellScriptBin "wallpaper-switcher" ''
    #!/usr/bin/env bash

    WALLPAPER_DIR="$HOME/.config/wallpapers"
    CURRENT_WALLPAPER_FILE="$HOME/.config/swww/current_wallpaper"

    # Ensure directories exist
    mkdir -p "$WALLPAPER_DIR" "$(dirname "$CURRENT_WALLPAPER_FILE")"

    # Get current focused monitor
    FOCUSED_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

    if [ -z "$FOCUSED_MONITOR" ]; then
        echo "No focused monitor found"
        exit 1
    fi

    # Get all wallpapers
    WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) | sort))

    if [ ''${#WALLPAPERS[@]} -eq 0 ]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        notify-send "Wallpaper Switcher" "No wallpapers found in ~/.config/wallpapers" -u normal
        exit 1
    fi

    # Read current wallpaper index for this monitor
    CURRENT_INDEX=0
    if [ -f "$CURRENT_WALLPAPER_FILE.$FOCUSED_MONITOR" ]; then
        CURRENT_INDEX=$(cat "$CURRENT_WALLPAPER_FILE.$FOCUSED_MONITOR" 2>/dev/null || echo 0)
    fi

    # Calculate next index
    NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ''${#WALLPAPERS[@]} ))

    # Get the wallpaper path
    WALLPAPER_PATH="''${WALLPAPERS[$NEXT_INDEX]}"

    # Set wallpaper on focused monitor
    swww img --outputs "$FOCUSED_MONITOR" "$WALLPAPER_PATH" --transition-fps 60 --transition-type wipe --transition-duration 1

    # Save current index for this monitor
    echo "$NEXT_INDEX" > "$CURRENT_WALLPAPER_FILE.$FOCUSED_MONITOR"

    # Get wallpaper name for notification
    WALLPAPER_NAME=$(basename "$WALLPAPER_PATH")
    notify-send "Wallpaper Changed" "Monitor: $FOCUSED_MONITOR\nWallpaper: $WALLPAPER_NAME" -u low

    echo "Set wallpaper $WALLPAPER_NAME on monitor $FOCUSED_MONITOR"
  '';

in {
  home.packages = with pkgs; [
    swww.packages.${system}.swww
    wallpaperSwitcher
    jq
    libnotify
  ];

  home.file.".config/wallpapers/.keep".text = "";

  home.file.".config/swww/.keep".text = "";

  systemd.user.services.swww = {
    Unit = {
      Description = "Simple Wayland Wallpaper daemon";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${swww.packages.${system}.swww}/bin/swww-daemon";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };

    Install = { WantedBy = [ "hyprland-session.target" ]; };
  };
}
