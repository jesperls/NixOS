{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.services.sunshine;
in
{
  options.mySystem.services.sunshine.enable = lib.mkEnableOption "the Sunshine game-streaming host";

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      package = pkgs.sunshine.override { cudaSupport = true; };
    };

    systemd.user.services.sunshine.environment = {
      LD_LIBRARY_PATH = "/run/opengl-driver/lib";
    };

    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
    '';
  };
}
