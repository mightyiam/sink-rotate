{
  perSystem =
    { pkgs, ... }:
    {
      checks.build = pkgs.callPackage ../pkgs/sink-rotate { };
    };
}
