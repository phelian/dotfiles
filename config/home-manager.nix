{ pkgs, lib, ... }:
{
    home.stateVersion = "23.11";
    home.username = "felix";
    home.homeDirectory = "/Users/felix";
    home.enableNixpkgsReleaseCheck = false;

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    imports = [
      ../modules/home-manager/direnv.nix
      ../modules/home-manager/git.nix
      ../modules/home-manager/zsh.nix
      ../modules/home-manager/vscode.nix
      # ../modules/home-manager/chrome.nix # Not available for apple silicon
      ./oh-my-zsh/default.nix
    ];

    home.packages = with pkgs; [
      iterm2
      obsidian
      spotify
      slack
      discord
      docker # cli
      watch

      adafruit-nrfutil

      # work customer #3
      keepassxc

      # bruno # Not available for apple silicon
      tree
      ack
    ];
}
