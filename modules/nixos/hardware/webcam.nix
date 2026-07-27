{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.mySystem.hardware.webcam.videoNr = lib.mkOption {
    type = lib.types.ints.unsigned;
    default = 2;
    description = "v4l2loopback device number for the virtual webcam.";
  };

  config = {
    boot.extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    boot.kernelModules = [ "v4l2loopback" ];

    boot.extraModprobeConfig = ''
      options v4l2loopback video_nr=${toString config.mySystem.hardware.webcam.videoNr} card_label="Virtual Webcam" exclusive_caps=1
    '';

    environment.systemPackages = with pkgs; [
      cameractrls-gtk4
      v4l-utils
    ];
  };
}
