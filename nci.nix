{ inputs, ... }:
{
  imports = [
    inputs.nci.flakeModule
  ];
  perSystem =
    { pkgs, ... }:
    {
      nci = {
        projects.sink-rotate.path = ./.;

        crates.sink-rotate.drvConfig.mkDerivation = {
          buildInputs = [ pkgs.makeWrapper ];
          postFixup = ''
            wrapProgram $out/bin/sink-rotate \
              --prefix PATH : ${pkgs.pipewire}/bin/pw-dump \
              --prefix PATH : ${pkgs.wireplumber}/bin/wpctl
          '';
        };

        toolchainConfig = {
          channel = "stable";
          components = [ "rust-analyzer" ];
        };
      };
    };
}
