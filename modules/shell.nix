{ inputs, ... }:
{
  flake-file.inputs.make-shell = {
    url = "github:nicknovitski/make-shell";
    flake = false;
  };

  imports = [ (inputs.make-shell + "/flake-module.nix") ];

  perSystem =
    { pkgs, config, ... }:
    {
      make-shells.default = {
        packages = [
          pkgs.gcc
          pkgs.rust-analyzer
        ];
        inputsFrom = [ config.checks.build ];
      };
    };
}
