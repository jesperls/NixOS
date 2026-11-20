{
  config,
  osConfig,
  pkgs,
  ...
}:

{
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris
      autoload
    ];
    config = {
      gpu-api = "vulkan";
      hwdec = if osConfig.mySystem.hardware.nvidia.enable then "nvdec" else "auto-safe";
      vo = "gpu-next";
      profile = "high-quality";
      target-colorspace-hint = "auto";
      save-position-on-quit = true;
      keep-open = true;
      screenshot-directory = config.xdg.userDirs.extraConfig.SCREENSHOTS;
      screenshot-format = "png";
    };
  };
}
