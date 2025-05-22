{
  perSystem =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      packages.default = pkgs.rustPlatform.buildRustPackage {
        pname = "sink-rotate";
        version = (lib.importTOML ./Cargo.toml).package.version;

        src = lib.fileset.toSource {
          root = ./.;
          fileset = lib.fileset.unions [
            ./Cargo.lock
            ./Cargo.toml
            ./fixtures
            ./src
          ];
        };

        cargoLock.lockFile = ./Cargo.lock;

        nativeBuildInputs = [ pkgs.makeWrapper ];

        postFixup = ''
          wrapProgram $out/bin/sink-rotate \
            --prefix PATH : ${lib.getExe' pkgs.pipewire "pw-dump"} \
            --prefix PATH : ${lib.getExe' pkgs.wireplumber "wpctl"}
        '';

        meta.mainProgram = "sink-rotate";
      };

      checks.build = config.packages.default;
    };
}
