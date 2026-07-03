{ config, lib, ... }:

{
  options.mySystem = {
    # User configuration
    user = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "The username of the primary user.";
      };
      fullName = lib.mkOption {
        type = lib.types.str;
        description = "The full name of the primary user.";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "The email of the primary user.";
      };
    };

    # System configuration
    system = {
      locale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "The system locale.";
      };
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Stockholm";
        description = "The system timezone.";
      };
      keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "se";
        description = "The keyboard layout.";
      };
      consoleKeyMap = lib.mkOption {
        type = lib.types.str;
        default = "sv-latin1";
        description = "The console key map.";
      };
      extraLocaleSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Extra locale settings.";
      };
      hostName = lib.mkOption {
        type = lib.types.str;
        default = "nixos";
        description = "The system hostname.";
      };
      stateVersion = lib.mkOption {
        type = lib.types.str;
        default = "26.05";
        description = "The system state version.";
      };
    };

    # Home Manager configuration
    home = {
      stateVersion = lib.mkOption {
        type = lib.types.str;
        default = "26.05";
        description = "The Home Manager state version.";
      };
    };

    # Repository / host paths
    paths = {
      repoRoot = lib.mkOption {
        type = lib.types.str;
        default = "/home/${config.mySystem.user.username}/nixos-config";
        description = "Absolute path to the local nixos-config checkout.";
      };

      hostDir = lib.mkOption {
        type = lib.types.str;
        default = "${config.mySystem.paths.repoRoot}/hosts/${config.mySystem.system.hostName}";
        description = "Absolute path to the current host directory inside the repo.";
      };

      packagesFile = lib.mkOption {
        type = lib.types.str;
        default = "${config.mySystem.paths.hostDir}/packages.nix";
        description = "Absolute path to the host-specific Home Manager packages file.";
      };
    };

    # Monitor configuration
    monitors = lib.mkOption {
      default = [ ];
      description = "List of monitor configurations.";
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption { type = lib.types.str; };
            resolution = lib.mkOption { type = lib.types.str; };
            refreshRate = lib.mkOption { type = lib.types.int; };
            position = lib.mkOption {
              type = lib.types.str;
              default = "0x0";
            };
            scale = lib.mkOption {
              type = lib.types.float;
              default = 1.0;
            };
            transform = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
            };
            vrr = lib.mkOption {
              type = lib.types.ints.between 0 3;
              default = 0;
              description = "Adaptive sync mode for this monitor (0 = off, 1 = on, 2 = fullscreen only, 3 = fullscreen with video/game content type).";
            };
            bitdepth = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.enum [
                  8
                  10
                ]
              );
              default = null;
              description = "Output bit depth (10 enables 10-bit output).";
            };
            disabled = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        }
      );
    };
  };
}
