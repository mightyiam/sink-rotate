{ inputs, ... }:
{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, config, ... }:
    {
      devshells.default.devshell = {
        packages = [ pkgs.gcc ];
        packagesFrom = [ config.packages.default ];
      };
    };
}
