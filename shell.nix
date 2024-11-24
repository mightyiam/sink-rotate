{ inputs, ... }:
{
  imports = [ inputs.devshell.flakeModule ];
  perSystem.nci.projects.sink-rotate.numtideDevshell = "default";
}
