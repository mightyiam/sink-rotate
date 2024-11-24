{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
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
    settings.global.excludes = [
      "fixtures/*"
      "CHANGELOG.md"
    ];
  };
}
