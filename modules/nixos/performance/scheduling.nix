{
  config,
  lib,
  pkgs,
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

  services.ananicy = lib.mkIf cfg.ananicy {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    settings = {
      cgroup_load = false;
      apply_sched = false;
    };
  };

  services.irqbalance.enable = cfg.irqbalance;
}
