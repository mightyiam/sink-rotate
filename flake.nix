{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nci.url = "github:yusdacra/nix-cargo-integration";
  inputs.nci.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        inputs.nci.flakeModule
        inputs.treefmt-nix.flakeModule
        ./release
      ];
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        nci.projects.sink-rotate.path = ./.;
        nci.crates.sink-rotate = {};
        nci.toolchainConfig.channel = "stable";
        nci.toolchainConfig.components = ["rust-analyzer"];

        devShells.default = config.nci.outputs.sink-rotate.devShell.overrideAttrs (old: {
          packages = [pkgs.nodejs_latest];
        });

        packages.default = config.nci.outputs.sink-rotate.packages.release;

        treefmt.projectRootFile = "flake.nix";
        treefmt.programs.alejandra.enable = true;
        treefmt.programs.rustfmt.enable = true;
        treefmt.programs.prettier.enable = true;
        treefmt.settings.global.excludes = ["fixtures/*"];
      };
    };
}
