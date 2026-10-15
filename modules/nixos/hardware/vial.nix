{
  pkgs,
  ...
}:

{
  users.groups.plugdev = { }; # qmk-udev-rules references plugdev.

  services.udev.packages = with pkgs; [
    qmk-udev-rules
  ];

  environment.systemPackages = with pkgs; [
    vial
  ];
}
