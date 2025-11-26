{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.mySystem.services.backup;
  user = config.mySystem.user;
in {
  options.mySystem.services.backup = {
    enable = mkEnableOption "Home Manager backup service";
  };

  config = mkIf cfg.enable {
    system.activationScripts.manageHomeManagerBackups =
      lib.stringAfter [ "users" ] ''
        BACKUP_DIR="/home/${user.username}/.config/home-manager-backups"
        echo "Managing home-manager backup files..."

        # Create backup directory if it doesn't exist
        mkdir -p "$BACKUP_DIR"
        chown ${user.username}:users "$BACKUP_DIR"

        # Find all .hm-backup files and move them to centralized location with timestamp
        ${pkgs.findutils}/bin/find /home/${user.username} -name "*.hm-backup" -type f 2>/dev/null | while read -r backup_file; do
          if [[ "$backup_file" != "$BACKUP_DIR"* ]]; then
            # Get relative path and filename
            rel_path="''${backup_file#/home/${user.username}/}"
            rel_path="''${rel_path%.hm-backup}"
            # Replace / with _ for flat storage
            safe_name="$(echo "$rel_path" | ${pkgs.gnused}/bin/sed 's/\//_/g')"
            timestamp=$(date +%Y%m%d-%H%M%S)
            
            # Move to centralized backup location
            mv "$backup_file" "$BACKUP_DIR/''${safe_name}_''${timestamp}.backup"
            chown ${user.username}:users "$BACKUP_DIR/''${safe_name}_''${timestamp}.backup"
          fi
        done

        # Keep only the last 3 backups for each config file
        for config_file in $(ls "$BACKUP_DIR" 2>/dev/null | ${pkgs.gnused}/bin/sed 's/_[0-9]\{8\}-[0-9]\{6\}\.backup$//' | sort -u); do
          ${pkgs.findutils}/bin/find "$BACKUP_DIR" -name "''${config_file}_*.backup" -type f 2>/dev/null | 
            sort -r | tail -n +4 | xargs -r rm -f
        done
      '';
  };
}
