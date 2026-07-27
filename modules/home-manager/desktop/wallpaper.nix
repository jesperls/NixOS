{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  src = inputs.linux-wallpaper-engine;

  linux-wallpaper-engine = pkgs.callPackage "${src}/distro/nix/package.nix" {
    inherit src;
    package = lib.importJSON "${src}/package.json";
    electron = pkgs.electron_39;
    bun2nix = src.inputs.bun2nix.packages.${pkgs.stdenv.hostPlatform.system}.bun2nix;
  };
in
{
  home.packages = [
    linux-wallpaper-engine
    pkgs.linux-wallpaperengine
  ];
}
