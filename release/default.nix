{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      semantic-release = pkgs.buildNpmPackage {
        pname = "semantic-release-with-plugins";
        version = "1.0.0";
        src = lib.fileset.toSource {
          root = ./semantic-release-with-plugins;
          fileset = lib.fileset.unions [
            ./semantic-release-with-plugins/package.json
            ./semantic-release-with-plugins/package-lock.json
          ];
        };
        npmDeps = pkgs.importNpmLock {
          npmRoot = ./semantic-release-with-plugins;
        };
        dontNpmBuild = true;
      };

      bump-version = pkgs.writeShellApplication {
        name = "bump-version";
        runtimeInputs = [ pkgs.cargo-edit ];
        text = ''
          cargo set-version "$@"
        '';
      };

      semantic-release-with-plugins = pkgs.writeShellApplication {
        name = "release-pr-tracker";
        runtimeInputs = [ bump-version ];
        text = ''
          ${semantic-release}/bin/semantic-release "$@"
        '';
      };
    in
    {
      make-shells.default.inputsFrom = [ semantic-release ];
      apps = {
        bump-version.program = bump-version;
        semantic-release.program = semantic-release-with-plugins;
      };
    };
}
