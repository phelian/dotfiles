{ pkgs, ... }:
let
  # AUTO_UPDATE_START - Do not edit manually, use update-claude-code.sh
  claude-code-latest = pkgs.claude-code.overrideAttrs (old: {
    version = "2.0.65";
    src = pkgs.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.0.65.tgz";
      hash = "sha256-LcHY7pdnRdeEwtb1Fi/GW6D5Rv3StiKsoXQc3CPDmQw=";
    };
  });
  # AUTO_UPDATE_END
in
{
    home.stateVersion = "25.05";
    home.username = "felix";
    home.homeDirectory = "/Users/felix";
    home.enableNixpkgsReleaseCheck = false;

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    imports = [
      ../modules/home-manager/fzf.nix
      ../modules/home-manager/atuin.nix
      ../modules/home-manager/zoxide.nix
      ../modules/home-manager/fd.nix
      # ../modules/home-manager/thefuck.nix
      ../modules/home-manager/direnv.nix
      ../modules/home-manager/git.nix
      # ../modules/home-manager/gitui.nix # temporarily disabled due to build issues on Apple Silicon
      ../modules/home-manager/zsh.nix
      ../modules/home-manager/eza.nix
      ../modules/home-manager/kubecolor.nix
      # ../modules/home-manager/ghostty.nix # broken
      # ../modules/home-manager/vscode.nix
      # ../modules/home-manager/chrome.nix # Dont use Chrome with homemanager as its annoying with 1passwordw
      ./oh-my-zsh/default.nix
    ];

    home.packages = with pkgs; [
      coreutils
      obsidian

      # Haxx
      just
      kubectx
      bruno
      tree
      ack
      watch
      asciinema
      asciinema-agg
      httpie
      gh
      delta
      claude-code-latest
      openssl

      # Entertainment
      spotify

      # Communication
      # whatsapp-for-mac # not working
      slack
      discord
    ];

    # Claude Code configuration
    home.file.".claude" = {
      source = ../.claude;
      recursive = true;
    };

}
