{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];
  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    programs = {
      alejandra.enable = true;
      prettier.enable = true;
      rustfmt.enable = true;
    };
    settings.global.excludes = [
      "fixtures/*"
      "CHANGELOG.md"
    ];
  };
}
