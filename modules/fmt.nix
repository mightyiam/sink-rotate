{ inputs, ... }:
{
  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    flake = false;
  };

  imports = [
    (inputs.treefmt-nix + "/flake-module.nix")
  ];
  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    programs = {
      nixfmt.enable = true;
      prettier.enable = true;
      rustfmt.enable = true;
      toml-sort = {
        enable = true;
        all = true;
      };
    };
    settings.global = {
      on-unmatched = "fatal";
      excludes = [
        "fixtures/*"
        "CHANGELOG.md"
      ];
    };
  };
}
