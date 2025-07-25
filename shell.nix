{ inputs, ... }:
{
  imports = [ inputs.make-shell.flakeModule ];

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
