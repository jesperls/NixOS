{ osConfig, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      gpu-api = "vulkan";
      hwdec = if osConfig.mySystem.hardware.nvidia.enable then "nvdec" else "auto-safe";
      vo = "gpu-next";
      profile = "high-quality";
      target-colorspace-hint = "auto";
    };
  };
}
