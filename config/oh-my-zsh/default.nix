{ config, ... } : {
  home.file.".oh-my-custom/themes/phelian.zsh-theme".source = config.lib.file.mkOutOfStoreSymlink ./themes/phelian.zsh-theme;
}