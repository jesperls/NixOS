{
  description = "NixOS configuration for jesperls";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deltatune = {
      url = "github:ThatOneCalculator/deltatune-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      shellVersion = self.shortRev or self.dirtyShortRev or "dev";

      overlays = import ./pkgs { inherit shellVersion; };

      hosts = import ./nix/hosts.nix {
        inherit
          lib
          inputs
          home-manager
          overlays
          ;
      };
    in
    {
      nixosConfigurations = hosts;

      overlays.default = overlays;

      packages.${system} = {
        inherit (pkgs.extend overlays) pangu ttf-phosphor-icons;
      };

      formatter.${system} = pkgs.nixfmt-tree;

      checks.${system} = import ./checks.nix {
        inherit
          lib
          pkgs
          hosts
          overlays
          ;
      };
    };
}
