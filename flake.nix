{
  description = "NixOS configuration for jesperls";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop
    hyprnix = {
      url = "github:hyprwm/hyprnix";
      # Drop when hyprnix bumps its aquamarine pin.
      inputs.aquamarine.url = "github:hyprwm/aquamarine/v0.13.0";
    };

    # Shared quickshell build for the local quickshell subprojects.
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ambxst = {
      url = "git+file:///home/jesperls/nixos-config/Ambxst";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems-linux.url = "github:nix-systems/default-linux";

    linux-wallpaper-engine = {
      url = "github:jagrat7/linux-wallpaper-engine";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.bun2nix.inputs.systems.follows = "systems-linux";
    };

    quickshell-package-manager = {
      url = "github:jesperls/nix-quickshell-package-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };

    # Kernel
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Applications
    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deltatune = {
      url = "github:ThatOneCalculator/deltatune-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qs-vpets = {
      url = "github:jesperls/qs-vpets";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
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
