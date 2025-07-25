{ inputs, ... }:
{
  imports = [ inputs.make-shell.flakeModules.default ];

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
