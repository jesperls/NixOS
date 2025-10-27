{ config, lib, pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    nerd-fonts.jetbrains-mono
    liberation_ttf
    dejavu_fonts
  ];
}
