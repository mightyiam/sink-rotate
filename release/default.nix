{
  perSystem =
    { pkgs, ... }:
    let
      semantic-release = pkgs.buildNpmPackage {
        pname = "semantic-release-with-plugins";
        version = "1.0.0";
        src = ./semantic-release-with-plugins;
        npmDepsHash = "sha256-h8nLyA/antqQYeab8JXLfSIPiXfL7ibbN5JKJKL66lE=";
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
