{ pkgs, ... }:

{
  boot.kernelModules = [
    "k10temp"
    "nct6775"
  ];

  environment.systemPackages = with pkgs; [
    lm_sensors
    nvtopPackages.full
  ];
}
