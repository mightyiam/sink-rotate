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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

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
        self',
        ...
      }: {
        nci = {
          projects.sink-rotate.path = ./.;

          crates.sink-rotate.drvConfig.mkDerivation = {
            buildInputs = [pkgs.makeWrapper];
            postFixup = ''
              wrapProgram $out/bin/sink-rotate \
                --prefix PATH : ${pkgs.pipewire}/bin/pw-dump \
                --prefix PATH : ${pkgs.wireplumber}/bin/wpctl
            '';
          };

          toolchainConfig = {
            channel = "stable";
            components = ["rust-analyzer"];
          };
        };

        devShells.default = config.nci.outputs.sink-rotate.devShell.overrideAttrs (old: {
          packages = [pkgs.nodejs_latest];
        });

        packages.default = config.nci.outputs.sink-rotate.packages.release;

        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            rustfmt.enable = true;
            prettier.enable = true;
          };
          settings.global.excludes = [
            "fixtures/*"
            "CHANGELOG.md"
          ];
        };

        checks.build = self'.packages.default;
      };
    };
}
