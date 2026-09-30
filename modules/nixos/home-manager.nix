{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  rotatingBackup = pkgs.callPackage ../../pkgs/hm-rotating-backup.nix { };
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupCommand = lib.getExe rotatingBackup;
    extraSpecialArgs = { inherit inputs; };
  };
}
