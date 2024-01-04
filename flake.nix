{
  description = "Nix for felix macOS configuration";

  inputs = {
    nixpkgs-unstable.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOs/nixpkgs/nixos-23.11";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs@{ self, nixpkgs-unstable, darwin, home-manager, ... }:{
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
    formatter.aarch64-darwin = nixpkgs-unstable.legacyPackages.x86_64-darwin.alejandra;
  };
}
