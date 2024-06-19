{
  description = "Nix for felix macOS configuration";

  inputs = {
    # nixpkgs-unstable.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.05";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "darwin";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, flake-utils, ... }:{
    darwinConfigurations.sculpin = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix

        # `home-manager` module
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.felix = import ./config/home-manager.nix;
        }
      ];
    };

    # nix code formatter
    formatter.aarch64-darwin = nixpkgs.legacyPackages.x86_64-darwin.alejandra;
  }
  # devShells
  // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      update = pkgs.writeScriptBin "update" "nix flake update --commit-lock-file";
      build = pkgs.writeShellApplication {
        name = "build";
        runtimeInputs = [ pkgs.nvd pkgs.home-manager ];
        text = ''
          # first run: no current generation exists so use ./result (diff against oneself)
          current=$( (home-manager generations 2> /dev/null || echo result) | head -n 1 | awk '{ print $7 }')
          darwin-rebuild build --flake ".#$(hostname -s | awk '{ print tolower($1) }')" && nvd diff "$current" result
        '';
      };
      switch = pkgs.writeShellApplication {
        name = "switch";
        runtimeInputs = [ pkgs.home-manager ];
        text = ''
          darwin-rebuild switch --flake ".#$(hostname -s | awk '{ print tolower($1) }')"'';
      };
    in {
      devShell = pkgs.mkShell { buildInputs = [ update build switch ]; };
    });
}
