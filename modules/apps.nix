{ pkgs, ...}: 
{
  imports = [
    ../config/homebrew.nix
  ];

  ##########################################################################
  #  Install all apps and packages here.
  #    https://daiderd.com/nix-darwin/manual/index.html
  ##########################################################################

  # Install packages from nix's official package repository.

  environment.systemPackages = with pkgs; [
    # _1password_gui # https://github.com/NixOS/nixpkgs/issues/254944
  ];
}
