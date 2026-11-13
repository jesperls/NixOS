{
  config,
  pkgs,
  ...
}:

{
  environment.systemPackages = [
    pkgs.lm_sensors
    (
      if config.mySystem.hardware.nvidia.enable then pkgs.nvtopPackages.nvidia else pkgs.nvtopPackages.amd
    )
  ];
}
