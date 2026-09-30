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
        cudaSupport = config.mySystem.hardware.nvidia.enable or false;
      }
    );
  };

  systemd.user.services.sunshine.serviceConfig.ExecStart = lib.mkForce (
    "${lib.getExe config.services.sunshine.package} capture=wlr" # CLI overrides preserve mutable web UI settings.
  );
}
