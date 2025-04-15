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
      ../modules/home-manager/zoxide.nix
      ../modules/home-manager/fd.nix
      ../modules/home-manager/thefuck.nix
      ../modules/home-manager/direnv.nix
      ../modules/home-manager/git.nix
      ../modules/home-manager/gitui.nix
      ../modules/home-manager/zsh.nix
      # ../modules/home-manager/ghostty.nix # broken
      # ../modules/home-manager/vscode.nix
      # ../modules/home-manager/chrome.nix # Not available for apple silicon
      ./oh-my-zsh/default.nix
    ];

    home.packages = with pkgs; [
      coreutils
      iterm2
      obsidian

      # Haxx
      just
      kubectx
      adafruit-nrfutil
      bruno
      tree
      ack
      watch
      asciinema
      asciinema-agg
      httpie

      # Entertainment
      spotify

      # Communication
      # whatsapp-for-mac # not working
      slack
      discord
    ];
}
