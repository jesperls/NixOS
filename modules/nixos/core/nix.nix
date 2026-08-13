{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    channel.enable = false;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-outputs = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
      warn-dirty = false;
      min-free = 1073741824; # 1 GiB
      max-free = 5368709120; # 5 GiB

      http-connections = lib.mkDefault 64;
      max-substitution-jobs = lib.mkDefault 32;
      download-buffer-size = lib.mkDefault 536870912; # 512 MiB

      connect-timeout = 5;
      fallback = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://attic.xuyh0120.win/lantian"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    optimise.automatic = true;
  };
  nixpkgs.config.allowUnfree = true;

  documentation.nixos.enable = false;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep ${toString config.mySystem.system.keepGenerations}";
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
    ];
  };
}
