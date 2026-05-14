{ inputs, ... }:
{
  imports = [ (inputs.make-shell + "/flake-module.nix") ];

  perSystem =
    { pkgs, config, ... }:
    {
      make-shells.default = {
        packages = [
          pkgs.gcc
          pkgs.rust-analyzer
        ];
        inputsFrom = [ config.packages.default ];
      };
    };
}
