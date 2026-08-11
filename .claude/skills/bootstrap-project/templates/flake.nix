{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # fpcloud only — drop with the rest of the fpcloud wiring below.
    fpcloud.url = "github:fogpipe/cloud-cli";
  };

  outputs = { nixpkgs, flake-utils, fpcloud, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # allowUnfree is only needed because the fpcloud binary is proprietary. Drop it
        # otherwise — nothing else in this shell is unfree (opentofu is MPL, terraform is not).
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        fpcloudCli = fpcloud.packages.${system}.default;

        # `fpcloud auth configure-docker` registers "fpcloud" as a credential helper, and docker
        # then shells out to `docker-credential-fpcloud` by that exact name. The upstream package
        # only installs `fpcloud`, so without this alias `just image-push` fails to authenticate.
        dockerCredentialFpcloud = pkgs.runCommand "docker-credential-fpcloud" { } ''
          mkdir -p $out/bin
          ln -s ${fpcloudCli}/bin/fpcloud $out/bin/docker-credential-fpcloud
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            {{BUILD_INPUTS}}
          ];

          shellHook = ''
            {{SHELL_HOOK}}
          '';
        };
      }
    );
}
