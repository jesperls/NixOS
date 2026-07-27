{ config, lib, ... }:

let
  cfg = config.mySystem.services.docker;
in
{
  options.mySystem.services.docker.enable = lib.mkEnableOption "the Docker daemon";

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    hardware.nvidia-container-toolkit.enable = lib.elem "nvidia" config.services.xserver.videoDrivers;
  };
}
