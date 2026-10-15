{ config, ... }:

{
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = config.mySystem.hardware.nvidia.enable;
}
