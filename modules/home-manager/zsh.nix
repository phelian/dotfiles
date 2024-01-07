{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;

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
    '';

    initExtra = ''
      function extra_space() {
        if [[ $KUBE_PS1_ENABLED == "on" ]]; then
          echo " ";
        fi
      }

      export PROMPT='$(kube_ps1)$(extra_space)'$PROMPT
    '';

    dirHashes = {
      dotfiles = "$HOME/src/phelian/dotfiles";
      dl  = "$HOME/Downloads";
    };
  };
}