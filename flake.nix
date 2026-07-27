{
  description = "NixOS configuration for jesperls";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprnix = {
      url = "github:hyprwm/hyprnix";
      inputs.aquamarine.url = "github:hyprwm/aquamarine/v0.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems-linux";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems-linux.url = "github:nix-systems/default-linux";

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors/f5ba36c7622098b53bf62ddb8ddf03b914abbdf8";
      inputs.hyprland.follows = "hyprnix/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    linux-wallpaper-engine = {
      url = "github:jagrat7/linux-wallpaper-engine";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.bun2nix.inputs.systems.follows = "systems-linux";
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
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deltatune = {
      url = "github:ThatOneCalculator/deltatune-linux";
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

      mkHost =
        hostName:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostName}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                self.overlays.default
                (final: _: {
                  quickshell = inputs.quickshell.packages.${final.stdenv.hostPlatform.system}.default;
                })
              ];
            }
          ];
        };

      hosts = lib.genAttrs [ "pangu" ] mkHost;
    in
    {
      nixosConfigurations = hosts;

      overlays.default = import ./pkgs;

      packages.${system} = {
        inherit (pkgs.extend self.overlays.default) pangu ttf-phosphor-icons;
      };

      formatter.${system} = pkgs.nixfmt-tree;

      checks.${system} = lib.mapAttrs' (
        hostName: host: lib.nameValuePair "${hostName}-system" host.config.system.build.toplevel
      ) hosts;
    };
}
