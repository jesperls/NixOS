{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let system = "x86_64-linux";
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
}
