{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nci = {
      url = "github:yusdacra/nix-cargo-integration";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        parts.follows = "flake-parts";
        treefmt.follows = "treefmt-nix";
      };
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default-linux";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        ./fmt.nix
        ./nci.nix
        ./release
        ./shell.nix
      ];
      perSystem =
        {
          config,
          self',
          ...
        }:
        {
          packages.default = config.nci.outputs.sink-rotate.packages.release;
          checks.build = self'.packages.default;
        };
    };
}
