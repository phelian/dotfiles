{
  pkgs,
  config,
  ...
}: {
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
      # Removed zsh-gcloud-prompt - replaced with custom_gcloud_prompt function
    ];

    sessionVariables = {
      EDITOR = "vim";
    };

    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval $(dircolors -b)
    '';

    initContent = ''
      function watch() {
        local input="$*"
        input=$(echo "$input" | sed 's/^kubectl /kubecolor /')

        # Escape for bash -c
        input_escaped=$(printf "%q" "$input")

        KUBECOLOR_FORCE_COLOR=1 command watch -c "script -q /dev/null bash -c $input_escaped"
      }

      pretty_path() {
        echo "$PATH" | tr ':' '\n'
      }

      # Make Zsh history instantly written and shared across terminals
      setopt share_history
      setopt hist_save_no_dups
      setopt hist_ignore_space
      setopt hist_find_no_dups

      export PATH=$HOME/.local/bin:$PATH:$HOME/bin
      export HISTSIZE=1000000

      # Source private environment variables if they exist
      # This file is git-ignored and allows you to set sensitive env vars
      # See README.md for details
      [[ -f "$HOME/.private-env.zsh" ]] && source "$HOME/.private-env.zsh"

      bindkey "\e\e[D" backward-word # ALT-left-arrow  ⌥ + ←
      bindkey "\e\e[C" forward-word  # ALT-right-arrow ⌥ + →
      alias ls='ls -G --color=auto'
      alias copy='clipcopy'
      alias kubectl='kubecolor --kubecolor-theme=protanopia-dark'

      # fzf: make alt-c cd work https://github.com/junegunn/fzf/issues/164
      export FZF_ALT_C_OPTS="--walker-skip='.git,node_modules,.venv,cdk.out,.direnv,__pycache__,dist,build,.terraform, \
        .idea,.vscode,.Trash,.cargo,.go,tmp,.nx,Downloads,Desktop,Documents,Library,Movies,Music,Pictures,Public, \
        .docker,.cache,.colima,go/bin/**,go/src/**,go/pkg/**,.nix-profile'"
      bindkey "ç" fzf-cd-widget

      _load_project_completions() {
        [[ -f .zsh_completions ]] && source .zsh_completions
      }
      add-zsh-hook chpwd _load_project_completions
      _load_project_completions

      # Load globally-dropped completions (e.g. fp-cloud's dev shell refreshes
      # ~/.zsh/completions/_fpcloud). oh-my-zsh owns compinit and runs it before
      # any home-manager fpath tweak lands, so we source these afterwards —
      # cobra-style scripts self-register via compdef on source.
      if [[ -d "$HOME/.zsh/completions" ]]; then
        for _comp in "$HOME"/.zsh/completions/*(.N); do source "$_comp"; done
        unset _comp
      fi

      _just() {
        [[ $words[CURRENT] == -* ]] && { _files; return }
        local -a names cands
        names=(''${(z)"$(just --summary 2>/dev/null)"})
        cands=("''${(@f)$(_CLAP_IFS=$'\n' _CLAP_COMPLETE_INDEX=$((CURRENT-1)) JUST_COMPLETE=zsh just -- "''${words[@]}" 2>/dev/null)}")
        cands=(''${(M)cands:#(''${(j:|:)~names})(:*|)})
        _describe -t recipes 'recipe' cands
      }
      compdef _just just
    '';

    dirHashes = {
      dotfiles = "$HOME/src/phelian/dotfiles";
      dl = "$HOME/Downloads";
    };
  };
}
