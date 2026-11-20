{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = false;
    openFirewall = true;
    package = lib.mkDefault (
      pkgs.sunshine.override {
        cudaSupport = config.mySystem.hardware.nvidia.enable;
      }
    );
  };

  systemd.user.services.sunshine = {
    after = [ "pangu.service" ];
    unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
    serviceConfig = {
      Slice = "session.slice";
      ExecStart = lib.mkForce (
        "${lib.getExe config.services.sunshine.package} capture=wlr" # CLI overrides preserve mutable web UI settings.
      );
    };
  };
}
