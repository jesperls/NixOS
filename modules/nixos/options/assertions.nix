{ config, ... }:

let
  cfg = config.mySystem;
in
{
  config.assertions = [
    {
      assertion = config.programs.hyprland.enable -> builtins.any (m: !m.disabled) cfg.monitors;
      message = "mySystem.monitors needs at least one enabled monitor; workspace and special-workspace layout math depends on it.";
    }
    {
      assertion = builtins.elem cfg.desktop.layouts.default cfg.desktop.layouts.cycle;
      message = "mySystem.desktop.layouts.default (${cfg.desktop.layouts.default}) must be one of mySystem.desktop.layouts.cycle, or the layout toggle can never cycle back to it.";
    }
  ];
}
