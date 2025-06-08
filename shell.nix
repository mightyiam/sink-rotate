{ inputs, ... }:
{
  imports = [ inputs.make-shell.flakeModule ];

  perSystem =
    { pkgs, config, ... }:
    {
      make-shells.default = {
        packages = [ pkgs.gcc ];
        inputsFrom = [ config.packages.default ];
      };
    };
}
