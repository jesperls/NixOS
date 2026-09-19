{
  lib,
  inputs,
  home-manager,
  overlays,
}:

let
  mkHost =
    hostName:
    {
      system ? "x86_64-linux",
      modules ? [ ],
    }:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ../hosts/${hostName}/configuration.nix
        home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            overlays
            (_final: _prev: {
              opencode = inputs.opencode.packages.${system}.opencode;
            })
          ];
        }
      ]
      ++ modules;
    };
in
lib.mapAttrs mkHost {
  pangu = { };
  gonggong = { };
}
