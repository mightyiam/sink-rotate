{
  clippy,
  lib,
  makeWrapper,
  pipewire,
  rustPlatform,
  wireplumber,
}:
rustPlatform.buildRustPackage {
  pname = "sink-rotate";
  version = (lib.importTOML ../../Cargo.toml).package.version;

  src = lib.fileset.toSource {
    root = ../..;
    fileset = lib.fileset.unions [
      ../../Cargo.lock
      ../../Cargo.toml
      ../../fixtures
      ../../src
    ];
  };

  cargoLock.lockFile = ../../Cargo.lock;

  env.RUSTFLAGS = "--deny warnings";

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ clippy ];

  preCheck = ''
    cargo clippy --all-targets --all-features
  '';

  postFixup = ''
    wrapProgram $out/bin/sink-rotate \
      --prefix PATH : ${lib.getExe' pipewire "pw-dump"} \
      --prefix PATH : ${lib.getExe' wireplumber "wpctl"}
  '';

  meta.mainProgram = "sink-rotate";
}
