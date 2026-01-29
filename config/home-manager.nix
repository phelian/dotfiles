{ pkgs, ... }:
let
  # AUTO_UPDATE_START - Do not edit manually, use update-claude-code.sh
  claude-code-latest = pkgs.claude-code.overrideAttrs (old: {
    version = "2.1.2";
    src = pkgs.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.1.2.tgz";
      hash = "sha256-PpNXyZ3xoZ/4lCvtErltkdsL/1hDRyiicblvhykgROw=";
    };
  });
  # AUTO_UPDATE_END

  # OPENCODE_UPDATE_START - Do not edit manually, use update_opencode.sh
  opencode-latest = pkgs.opencode.overrideAttrs (old: {
    version = "1.1.41";
    src = pkgs.fetchzip {
      url = "https://github.com/anomalyco/opencode/archive/refs/tags/v1.1.41.tar.gz";
      hash = "sha256-p4mZRJ+BQs790hjCOJ9iXzg3JoCa4lqOdCqDRkoEfWw=";
    };
  });
  # OPENCODE_UPDATE_END

  gsdVersion = "1.9.6";
  gsdSrc = pkgs.fetchzip {
    url = "https://registry.npmjs.org/get-shit-done-cc/-/get-shit-done-cc-${gsdVersion}.tgz";
    hash = "sha256-mBCzUzbjJ3/DT7mf1FCOMmMtAy8FY5LO30PT8kv7LxA=";
  };
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
      # claude-code
      claude-code-latest
      opencode-latest
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
