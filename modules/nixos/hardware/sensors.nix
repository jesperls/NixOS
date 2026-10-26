{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    lm_sensors
    nvtopPackages.nvidia
  ];
}
