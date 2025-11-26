{ lib, pkgs, ... }:

with lib;

{
  options.mySystem = {
    user = {
      username = mkOption {
        type = types.str;
        description = "The username of the primary user.";
      };
      fullName = mkOption {
        type = types.str;
        description = "The full name of the primary user.";
      };
      email = mkOption {
        type = types.str;
        description = "The email of the primary user.";
      };
    };

    system = {
      locale = mkOption {
        type = types.str;
        default = "en_US.UTF-8";
        description = "The system locale.";
      };
      timeZone = mkOption {
        type = types.str;
        default = "Europe/Stockholm";
        description = "The system timezone.";
      };
      keyboardLayout = mkOption {
        type = types.str;
        default = "se";
        description = "The keyboard layout.";
      };
      consoleKeyMap = mkOption {
        type = types.str;
        default = "sv-latin1";
        description = "The console key map.";
      };
      extraLocaleSettings = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Extra locale settings.";
      };
      hostName = mkOption {
        type = types.str;
        default = "nixos";
        description = "The system hostname.";
      };
      stateVersion = mkOption {
        type = types.str;
        default = "25.05";
        description = "The system state version.";
      };
    };

    monitors = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of monitor configurations for Hyprland.";
    };
  };
}
