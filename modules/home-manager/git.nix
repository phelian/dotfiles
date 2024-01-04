{
  programs.git = {
    enable = true;
    userName = "Alexander Félix";
    userEmail = "alexander.felix83@gmail.com";

    ignores = [ ".DS_Store" ];

    extraConfig = {
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