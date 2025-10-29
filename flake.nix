{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    swww = {
      url = "github:LGFae/swww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, swww, ... }:
    let
      system = "x86_64-linux";
      userConfig = import ./user.nix;
    in {
      nixosConfigurations.${userConfig.hostname} = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          home-manager.nixosModules.home-manager
          { _module.args = { inherit userConfig swww; }; }
        ];
      };
    };
}
