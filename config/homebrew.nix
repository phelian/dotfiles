{
  # To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    # taps = [
    #   # "homebrew/cask"
    #   "homebrew/cask-fonts"
    #   "homebrew/services"
    #   "homebrew/cask-versions"
    # ];

    # `brew install`
    brews = [
    ];

    # `brew install --cask`
    casks = [
      "google-chrome"
      "discord"
      "whatsapp"
      "telegram"
      # "postico" Download 1 manually
      "google-drive"
      "gitx"
      "linear-linear"
    ];
  };
}