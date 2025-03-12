{ pkgs, lib, ... }:
{
    home.stateVersion = "25.05";
    home.username = "felix";
    home.homeDirectory = "/Users/felix";
    home.enableNixpkgsReleaseCheck = false;

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    imports = [
      ../modules/home-manager/fzf.nix
      ../modules/home-manager/direnv.nix
      ../modules/home-manager/git.nix
      ../modules/home-manager/zsh.nix
      # ../modules/home-manager/vscode.nix
      # ../modules/home-manager/chrome.nix # Not available for apple silicon
      ./oh-my-zsh/default.nix
    ];

    home.packages = with pkgs; [
      coreutils
      iterm2
      obsidian
      spotify
      slack
      discord
      # docker # cli
      watch
      asciinema
      # agg Does not compile, using homebrew

      adafruit-nrfutil

      # bruno # Not available for apple silicon
      tree
      ack
    ];
}
