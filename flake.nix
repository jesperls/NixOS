{
  description = "NixOS configuration for jesperls";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixcord.url = "github:FlameFlag/nixcord";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop
    hyprnix = {
      url = "github:hyprwm/hyprnix";
    };

    caelestia-shell = {
      url = "github:jesperls/caelestia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpaper-picker = {
      url = "github:jesperls/wallpaper-picker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell-package-manager = {
      url = "github:jesperls/nix-quickshell-package-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Kernel
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    # Applications
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deltatune = {
      url = "github:ThatOneCalculator/deltatune-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    myna = {
      url = "github:SmoxBoye/myna";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qs-vpets = {
      url = "github:jesperls/qs-vpets";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "caelestia-shell/quickshell";
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
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      specialArgs = { inherit inputs; };

      pangu = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/pangu/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      checks.${system}.pangu-system = pangu.config.system.build.toplevel;

      nixosConfigurations = {
        inherit pangu;
      };
    };
}
