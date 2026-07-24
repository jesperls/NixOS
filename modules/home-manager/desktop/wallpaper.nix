{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  src = inputs.linux-wallpaper-engine;

  # Upstream still pins an EOL electron; scope the exception to this package
  # instead of loosening nixpkgs.config for the whole system.
  lwePkgs = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowInsecurePredicate = p: lib.getName p == "electron";
  };

  linux-wallpaper-engine = lwePkgs.callPackage "${src}/distro/nix/package.nix" {
    inherit src;
    package = lib.importJSON "${src}/package.json";
    electron = lwePkgs.electron_39;
    bun2nix = src.inputs.bun2nix.packages.${pkgs.stdenv.hostPlatform.system}.bun2nix;
  };
in
{
  home.packages = [
    linux-wallpaper-engine
    pkgs.linux-wallpaperengine # renderer both the GUI and Ambxst's picker drive
  ];

  # Restores the wallpapers Ambxst's picker last applied; Ambxst's
  # scripts/wallpaperengine.sh writes back into this app's state.
  systemd.user.services.linux-wallpaper-engine = import ../lib/autostart.nix {
    description = "Linux Wallpaper Engine — Wallpaper Engine renderer manager";
    execStart = "${linux-wallpaper-engine}/bin/linux-wallpaper-engine";
    unit.ConditionEnvironment = "WAYLAND_DISPLAY";
    service.Restart = "no";
  };
}
