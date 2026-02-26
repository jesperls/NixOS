{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  boot.kernelModules = [ "v4l2loopback" ];

  boot.extraModprobeConfig = ''
    options v4l2loopback video_nr=2 card_label="Virtual Webcam" exclusive_caps=1
  '';

  environment.systemPackages = with pkgs; [
    cameractrls-gtk4
    v4l-utils
  ];
}
