
{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # enable flakes globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.package = pkgs.nix;
  programs.nix-index.enable = true;
  ids.gids.nixbld = 30000;
}
