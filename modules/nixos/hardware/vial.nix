{ pkgs, ... }:

{
  services.udev.packages = with pkgs; [
    qmk-udev-rules
  ];

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess"
  '';

  environment.systemPackages = with pkgs; [
    vial
  ];
}
