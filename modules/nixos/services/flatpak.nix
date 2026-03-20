{ pkgs, ... }:

{
  services.flatpak.enable = true;
  environment.systemPackages = [ pkgs.xdg-utils ];
}
