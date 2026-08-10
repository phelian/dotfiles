{ config, ... } : {
  home.file.".oh-my-custom/themes/phelian.zsh-theme".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/src/github.com/phelian/dotfiles/config/oh-my-zsh/themes/phelian.zsh-theme";
}
