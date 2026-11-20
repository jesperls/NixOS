{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.nix-index-database.nixosModules.default ];

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    channel.enable = false;

    settings = {
      nix-path = [ "nixpkgs=flake:nixpkgs" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "@wheel" ];
      warn-dirty = false;
      min-free = 1024 * 1024 * 1024;
      max-free = 5 * 1024 * 1024 * 1024;

      http-connections = lib.mkDefault 64;
      max-substitution-jobs = lib.mkDefault 32;
      download-buffer-size = lib.mkDefault (512 * 1024 * 1024);

      connect-timeout = 5;
      fallback = true;
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };
  nixpkgs.config.allowUnfree = true;

  documentation.nixos.enable = false;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep ${toString config.mySystem.system.keepGenerations}";
    flake = config.mySystem.paths.repoRoot;
  };

  systemd.services.nh-clean = lib.mkIf config.programs.nh.clean.enable {
    serviceConfig = {
      Nice = 19;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
  };
  systemd.timers.nh-clean = lib.mkIf config.programs.nh.clean.enable {
    timerConfig.RandomizedDelaySec = "30min";
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.command-not-found.enable = false;
  programs.nix-index-database.comma.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      icu
      zlib
      libffi
      openssl
      dbus
      glib
    ];
  };
}
