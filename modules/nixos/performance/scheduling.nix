{
  config,
  lib,
  ...
}:

let
  cfg = config.mySystem.performance;
in
{
  services.scx = lib.mkIf (cfg.scheduler != null) {
    enable = true;
    scheduler = cfg.scheduler;
  };

  services.irqbalance.enable = lib.mkDefault true;
}
