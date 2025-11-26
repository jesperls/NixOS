{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/jesperls/nixos-config";
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.libc
      zlib
      libgbm

      nspr
      nss
      openssl
      libffi
      dbus

      mesa
      libdrm

      glib
      atk
      gtk3
      cairo
      pango
      expat
      alsa-lib
      cups
      fontconfig
      freetype

      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
      libxkbcommon
      wayland
      qt6.qtbase
      qt6.qtwayland
    ];
  };
}
