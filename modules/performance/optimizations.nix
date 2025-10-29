{ config, lib, pkgs, ... }:

{
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };
  hardware.cpu.intel.updateMicrocode = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 10;
    priority = 10;
  };

  services.thermald.enable = true;

  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables = {
    "__GL_SHADER_DISK_CACHE" = "1";
    "__GL_SHADER_DISK_CACHE_PATH" = "/tmp/nvidia-shader-cache";
  };
}