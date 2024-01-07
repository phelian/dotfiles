# Nix darwin / Home manager

This is my nix-darwin/home-manager/nix files that is heavily based on [ryan4yin](https://github.com/ryan4yin/nix-darwin-kickstarter) [jmatsushita](https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050), [phlmn](https://github.com/phlmn/nix-darwin-config/tree/main), [AxelTLarsson](https://github.com/AxelTLarsson/dotfiles) and others.

I leave all devtools out of this as they will be installed / project basis on direnv level instead.

## Prerequisites

1. Install Nix package manager via [Nix Official](https://nixos.org/download.html#nix-install-macos) or [The Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer)

2. Install Homebrew, see <https://brew.sh/>

Then you can run `make update` in the root of your nix configuration to deploy your configuration.

First time install

```bash
 nix build .#darwinConfigurations.sculpin.system --extra-experimental-features 'nix-command flakes'
./result/sw/bin/darwin-rebuild switch --flake .#sculpin
direnv allow
```

Afterwards
`build` Build and show updates
`switch` Update system

