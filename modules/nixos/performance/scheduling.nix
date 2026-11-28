{
  config,
  lib,
  ...
}:

let
  cfg = config.mySystem.performance;
in
{
  services.scx-loader = lib.mkIf (cfg.scheduler != null) {
    enable = true;
    config.default_sched = cfg.scheduler;
  };
}
