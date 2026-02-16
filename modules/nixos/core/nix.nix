{ config, pkgs, ... }:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      max-jobs = "auto";
      trusted-users = [
        "root"
        "@wheel"
      ];
      warn-dirty = false;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
    extraOptions = ''
      min-free = ${toString (1024 * 1024 * 1024)}
      max-free = ${toString (5 * 1024 * 1024 * 1024)}
    '';
  };

  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${config.mySystem.user.username}/nixos-config";
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.command-not-found.enable = false;
  environment.systemPackages = [ pkgs.comma ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Core C libraries
      stdenv.cc.cc.lib
      stdenv.cc.libc

      # Python essentials - these are critical for uv-managed Python
      zlib
      libffi
      openssl
      openssl.dev
      readline
      ncurses
      bzip2
      xz
      sqlite
      tk
      tcl
      gdbm
      expat
      libxcrypt

      # Graphics/GUI (for matplotlib, tkinter, etc.)
      libgbm
      mesa
      libdrm
      libx11
      libxext
      libxrender
      libxcomposite
      libxdamage
      libxfixes
      libxrandr
      libxcb
      libxcursor
      libxi
      libxinerama
      libxscrnsaver
      libxtst
      libxkbcommon
      wayland

      # Desktop integration
      nspr
      nss
      dbus
      glib
      atk
      gtk3
      cairo
      pango
      gdk-pixbuf
      alsa-lib
      cups
      fontconfig
      freetype

      # Qt
      qt6.qtbase
      qt6.qtwayland

      # Additional libraries for common Python packages
      libGL
      libGLU
      libuuid
      libxml2
      libxslt
      icu
    ];
  };
}
