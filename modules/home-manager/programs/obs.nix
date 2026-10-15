{
  pkgs,
  lib,
  osConfig,
  ...
}:

{
  programs.obs-studio = {
    enable = true;

    package = lib.mkDefault (
      pkgs.obs-studio.override {
        cudaSupport = osConfig.mySystem.hardware.nvidia.enable;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      obs-pipewire-audio-capture
      obs-gstreamer
    ];
  };
}
