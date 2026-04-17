{ pkgs, ... }:

{
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess"
  '';

  environment.systemPackages = with pkgs; [
    vial
  ];
}
