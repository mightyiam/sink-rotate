{ inputs, ... }:
{
  flake-file.inputs.files = {
    url = "github:mightyiam/files";
    flake = false;
  };
  imports = [ (inputs.files + "/flake-module.nix") ];
  perSystem = psArgs: {
    files.gitToplevel = ../.;
    make-shells.default.packages = [ psArgs.config.files.writer.drv ];
  };
}
