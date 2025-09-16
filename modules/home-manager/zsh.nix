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
        # "per-directory-history"
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
      eval "$(zoxide init zsh --cmd cd)"
    '';

    initContent = ''
      function extra_space() {
        if [[ $KUBE_PS1_ENABLED == "on" ]]; then
          echo " ";
        fi
      }

      function watch() {
        local input="$*"
        input=$(echo "$input" | sed 's/^kubectl /kubecolor /')

        # Escape for bash -c
        input_escaped=$(printf "%q" "$input")

        KUBECOLOR_FORCE_COLOR=1 command watch -c "script -q /dev/null bash -c $input_escaped"
      }

      # Make Zsh history instantly written and shared across terminals
      setopt share_history
      setopt hist_save_no_dups
      setopt hist_ignore_space
      setopt hist_find_no_dups

      export PROMPT='$(kube_ps1)$(extra_space)'$PROMPT
      export PATH=$PATH:$HOME/bin
      export HISTSIZE=1000000
      # [[ -f "$HOME/.shared-history-paths.zsh" ]] && source "$HOME/.shared-history-paths.zsh"

      bindkey "\e\e[D" backward-word # ALT-left-arrow  ⌥ + ←
      bindkey "\e\e[C" forward-word  # ALT-right-arrow ⌥ + →
      alias ls='ls -G --color=auto'
      alias kubectl='kubecolor --kubecolor-theme=protanopia-dark'

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
