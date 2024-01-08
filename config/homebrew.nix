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

    # `brew install`
    brews = [
    ];

    # `brew install --cask`
    casks = [
      "google-chrome"
      "whatsapp"
      "telegram"
      # "postico" Download 1 manually
      "google-drive"
      "gitx"
      "linear-linear"
      "bruno" # home manager does not have aarch64
    ];
  };
}