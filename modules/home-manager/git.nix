{
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