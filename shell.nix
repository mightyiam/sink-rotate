{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      devShells.default = config.nci.outputs.sink-rotate.devShell.overrideAttrs (old: {
        packages = [ pkgs.nodejs_latest ];
      });
    };
}
