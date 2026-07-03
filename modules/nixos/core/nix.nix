{ config, pkgs, ... }:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      keep-outputs = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
      warn-dirty = false;
      min-free = 1073741824; # 1 GiB
      max-free = 5368709120; # 5 GiB
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://attic.xuyh0120.win/lantian"
        "https://cache.garnix.io"
        "https://hyprland.cachix.org"
        "https://outfoxxed.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "outfoxxed.cachix.org-1:GNw2we0wPzUikP3lB3j/H5s8mBw6L3c6C1sXUoamg5Y="
      ];
    };

    optimise.automatic = true;
  };
  nixpkgs.config.allowUnfree = true;

  documentation.nixos.enable = false;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 5";
    flake = config.mySystem.paths.repoRoot;
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
      stdenv.cc.cc.lib
      icu
      libICE
      libSM
      libXext
      vulkan-loader
      zlib
      libffi
      openssl
      libGL
      libxkbcommon
      fontconfig
      freetype
      dbus
      glib
      libx11
      libxcursor
      libxrandr
      libxi
      libxcb
      xcbutilwm
      xcbutilimage
      xcbutilkeysyms
      xcbutilrenderutil
      xcbutilcursor
      wayland
      qt6.qtwayland
      alsa-lib
      config.boot.kernelPackages.nvidiaPackages.stable
    ];
  };
}
