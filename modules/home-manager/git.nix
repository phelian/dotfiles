{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "git-mine";
      runtimeInputs = [ pkgs.gawk pkgs.git ];
      text = ''
        me="<$(git config user.email)>"
        {
          echo 'branch local remote edited'
          git for-each-ref --format='%(authoremail) %(refname) %(committerdate:unix)' refs/heads refs/remotes |
            gawk -v me="$me" '$1==me{
              r=$2; t=$3
              if (r ~ /^refs\/heads\//) { sub(/^refs\/heads\//,"",r); L[r]=1; s[r]=1; if (t>D[r]) D[r]=t }
              else { sub(/^refs\/remotes\/[^/]*\//,"",r); if (r!="HEAD") { R[r]=1; s[r]=1; if (t>D[r]) D[r]=t } }
            } END { for (n in s) print n, (L[n]?"🟢":"🔴"), (R[n]?"🟢":"🔴"), strftime("%Y-%m-%d", D[n]) }' |
            sort --key=4,4 --reverse
        } | column -t
      '';
    })
  ];

  programs.git = {
    enable = true;

    ignores = [ ".DS_Store" ];

    settings = {
      user.name = "Alexander Félix";
      user.email = "alexander@fogpipe.com";
      init.defaultBranch = "main";
      merge.ff = "only";
      push.default = "simple";
      pull.ff = "only";
      rebase.autoSquash = true;
      url."git@github.com:".pushInsteadOf = "https://github.com";
      credential.helper = "store";
    };
  };
}
