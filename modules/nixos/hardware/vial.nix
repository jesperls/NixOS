{
  pkgs,
  ...
}:

{
  services.udev.packages = with pkgs; [
    qmk-udev-rules
  ];

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess"
  '';

  environment.systemPackages = with pkgs; [
    vial
  ];
}
