{ config, lib, ... }:

{
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = lib.elem "nvidia" config.services.xserver.videoDrivers;
}
