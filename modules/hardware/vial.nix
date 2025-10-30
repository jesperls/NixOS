{ config, lib, pkgs, ... }:

{
  services.udev.extraRules = ''
    # Vial keyboards - Universal rule for any device with Vial firmware
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

    # Generalized VIA rule - Allows access to all hidraw devices for VIA compatibility
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
}
