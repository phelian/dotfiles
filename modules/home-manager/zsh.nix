{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    autosuggestion = {
      enable = true;
    };

    shellAliases = {
      gs = "git status";
      w = "watch 'kubectl get pods --field-selector=status.phase!=Failed,status.phase!=Succeeded'";
      gpup = "git push --set-upstream origin $(git_current_branch)";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "history"
        "git"
        "github"
        "colorize"
        "kube-ps1"
        "kubectl"
        "docker"
        "per-directory-history"
      ];
      custom = "$HOME/.oh-my-custom";
      theme = "phelian";
    };

    plugins = [
      {
        name = "nix-shell";
        file = "nix-shell.plugin.zsh";
        src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
      }
    ];

    sessionVariables = {
      EDITOR = "vim";
    };

    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval $(dircolors -b)
    '';

    initExtra = ''
      function extra_space() {
        if [[ $KUBE_PS1_ENABLED == "on" ]]; then
          echo " ";
        fi
      }

      export PROMPT='$(kube_ps1)$(extra_space)'$PROMPT
      export USE_NIX=true
      export PATH=$PATH:$HOME/bin
      export HISTSIZE=100000

      bindkey "\e\e[D" backward-word # ALT-left-arrow  ⌥ + ←
      bindkey "\e\e[C" forward-word  # ALT-right-arrow ⌥ + →
      alias ls='ls -G --color=auto'
      eval $(thefuck --alias)

      # fzf: make alt-c cd work https://github.com/junegunn/fzf/issues/164

      export FZF_ALT_C_OPTS="--walker-skip='.git,node_modules,.venv,cdk.out,.direnv,__pycache__,dist,build,.terraform, \
        .idea,.vscode,.Trash,.cargo,.go,tmp,.nx,Downloads,Desktop,Documents,Library,Movies,Music,Pictures,Public, \
        .docker,.cache,.colima,go/bin/**,go/src/**,go/pkg/**,.nix-profile'"
      bindkey "ç" fzf-cd-widget
    '';

    dirHashes = {
      dotfiles = "$HOME/src/phelian/dotfiles";
      dl  = "$HOME/Downloads";
    };
  };
}