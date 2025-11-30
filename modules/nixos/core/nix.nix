{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${config.mySystem.user.username}/nixos-config";
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Standard C library
      stdenv.cc.libc
      zlib
      libgbm

      # Crypto and security
      nspr
      nss
      openssl
      libffi
      dbus

      # Graphics
      mesa
      libdrm

      # GTK and desktop libraries
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

      # X11 libraries
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb

      # Wayland support
      libxkbcommon
      wayland

      # Qt6 libraries
      qt6.qtbase
      qt6.qtwayland

      # CUDA libraries
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
      cudaPackages.libcublas
      cudaPackages.libcurand
      cudaPackages.libcufft
      config.boot.kernelPackages.nvidiaPackages.stable
    ];
  };
}
