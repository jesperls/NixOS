{ config, lib, pkgs, ... }:

{
  programs.dconf.enable = true;

  hardware.logitech.wireless.enable = true;
}
