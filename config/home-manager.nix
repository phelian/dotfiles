{
  pkgs,
  inputs,
  ...
}: let
  # OPENCODE_UPDATE_START - Do not edit manually, use update_opencode.sh
  opencodeVersion = "1.18.32";
  opencodeSrcHash = "sha256-h5AmK9R0Clk+LT0Tmmfg7iXa6dXNlPi2I5xCjTDRdcg=";
  opencodeNodeModulesHash = "sha256-MJB1szM+ms2cdEzf2mhhWIkE5+owvuvJf5dR74Wvpw0=";
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
  # COPILOT_UPDATE_START - Do not edit manually, use update_copilot.sh
  copilotVersion = "1.0.83";
  copilotHash = "sha256-yeOD2odEuEuqd33Spbxses1uQ1c2ALMNa9XTz8FTX7o=";
  # COPILOT_UPDATE_END
  copilot-cli = pkgs.stdenv.mkDerivation {
    pname = "copilot-cli";
    version = copilotVersion;
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@github/copilot-darwin-arm64/-/copilot-darwin-arm64-${copilotVersion}.tgz";
      hash = copilotHash;
    };
    unpackPhase = ''
      mkdir -p $out/lib/copilot-cli
      tar -xzf $src -C $out/lib/copilot-cli --strip-components=1
    '';
    installPhase = ''
      mkdir -p $out/bin
      chmod +x $out/lib/copilot-cli/copilot
      ln -s $out/lib/copilot-cli/copilot $out/bin/copilot
    '';
    dontStrip = true;
  };
in {
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
    ../modules/home-manager/notify-peer.nix
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
    gitea
    tea
    delta
    opencode-latest
    copilot-cli
    openssl
    exiftool
    inputs.codex-cli-nix.packages.${pkgs.system}.default

    # Entertainment
    spotify

    # Communication
    # whatsapp-for-mac # not working
    slack
    discord
  ];

  # Claude Code configuration (settings.json intentionally unmanaged so
  # the plugin manager can write to it)
  home.file.".claude/CLAUDE.md".source = ../.claude/CLAUDE.md;
  home.file.".claude/agents" = {
    source = ../.claude/agents;
    recursive = true;
  };
  home.file.".claude/commands" = {
    source = ../.claude/commands;
    recursive = true;
  };
  home.file.".claude/skills" = {
    source = ../.claude/skills;
    recursive = true;
  };
  home.file.".claude/statusline.ts" = {
    source = ../.claude/statusline.ts;
    executable = true;
  };
  home.file.".claude/themes" = {
    source = ../.claude/themes;
    recursive = true;
  };
}
