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

    pangu-shell = {
      url = "github:jesperls/Pangu-Shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deltatune = {
      url = "github:ThatOneCalculator/deltatune-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    foxy = {
      url = "github:jesperls/foxy-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    x1e-nixos-config = {
      url = "github:kuruczgy/x1e-nixos-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;

      overlays = lib.composeManyExtensions [
        inputs.pangu-shell.overlays.default
        (import ./pkgs)
      ];

      hosts = import ./nix/hosts.nix {
        inherit
          lib
          inputs
          home-manager
          overlays
          ;
      };

      hostsForSystem =
        system: lib.filterAttrs (_: host: host.pkgs.stdenv.hostPlatform.system == system) hosts;
    in
    {
      nixosConfigurations = hosts;

      overlays.default = overlays;

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend overlays;
        in
        {
          inherit (pkgs) pangu ttf-phosphor-icons;
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      checks = {
        x86_64-linux = import ./checks.nix {
          inherit
            lib
            hosts
            inputs
            ;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };

        aarch64-linux = lib.mapAttrs' (
          hostName: host: lib.nameValuePair "${hostName}-system" host.config.system.build.toplevel
        ) (hostsForSystem "aarch64-linux");
      };
    };
}
