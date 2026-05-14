{ inputs, ... }:
{
  imports = [
    (inputs.flake-file + "/modules/dendritic")
  ];
}
