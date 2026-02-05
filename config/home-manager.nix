{ pkgs, ... }:
let
  # AUTO_UPDATE_START - Do not edit manually, use update-claude-code.sh
  claude-code-latest = pkgs.claude-code.overrideAttrs (old: {
    version = "2.1.31";
    src = pkgs.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.1.31.tgz";
      hash = "sha256-nyTc982mwdela8uH7GO2ubMgD3sqpYmQP0adR4y25Ws=";
    };
  });
  # AUTO_UPDATE_END

  # OPENCODE_UPDATE_START - Do not edit manually, use update_opencode.sh
  opencodeVersion = "1.1.51";
  opencodeSrcHash = "sha256-i9KR5n6bT0p7xLErlgaq2TAj/B7ZbLd9a+4Czg8q/cI=";
  opencodeNodeModulesHash = "sha256-DChoXNWJFlyyAqeiR06BQMLITwVQXy0wvQs58l0d1Xc=";
  opencodeSrc = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${opencodeVersion}";
    hash = opencodeSrcHash;
  };
  opencode-latest = pkgs.opencode.overrideAttrs (old: {
    version = opencodeVersion;
    src = opencodeSrc;
    node_modules = old.node_modules.overrideAttrs {
      version = opencodeVersion;
      src = opencodeSrc;
      outputHash = opencodeNodeModulesHash;
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
      # bruno
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
