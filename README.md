# Nix darwin / Home manager

This is my nix-darwin/home-manager/nix files that is heavily based on [ryan4yin](https://github.com/ryan4yin/nix-darwin-kickstarter) [jmatsushita](https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050), [phlmn](https://github.com/phlmn/nix-darwin-config/tree/main), [AxelTLarsson](https://github.com/AxelTLarsson/dotfiles) and others.

I leave all devtools out of this as they will be installed / project basis on direnv level instead.

## Custom Prompt Configuration

The prompt is configured in `config/oh-my-zsh/themes/phelian.zsh-theme` and includes:
- Git repository name (when in a git repo) or current directory
- Git branch with oh-my-zsh styling
- Kubectl context (left side, only when active)
- GCloud account and project (right side, only when logged in)

### Toggle Prompt Style

You can switch between single-line and multi-line prompt styles:

```bash
toggle_prompt
```

- **Single-line**: Everything on one line (default)
- **Multi-line**: Prompt info on one line, cursor on the next

Your preference is saved and persists across terminal sessions.

### Private GCloud Account Display

The zsh prompt includes gcloud account information on the right side. To add custom displays for work or private accounts without exposing them in your public dotfiles, create a private configuration file:

**File: `~/.gcloud-prompt-accounts.zsh`** (git-ignored, lives outside this repo)

```zsh
# Private gcloud account prompt configurations
function custom_gcloud_account_display() {
  local account="$1"
  local project="$2"

  # Example: Work account with custom colors
  if [[ "$account" == "you@work.com" ]]; then
    if [[ -n "$project" ]]; then
      echo "%{$fg[yellow]%}[work%{$reset_color%}|%{$fg[cyan]%}$project%{$reset_color%}] "
    else
      echo "%{$fg[yellow]%}[work]%{$reset_color%} "
    fi
    return
  fi

  # Return empty to fall back to default public accounts
  echo ""
}
```

**Features:**
- Only displays if `gcloud` is installed
- Shows nothing if not logged in to gcloud
- Shows nothing if no kubectl context is active
- Fast - reads config files directly instead of running CLI commands
- Customizable colors using zsh color codes: `$fg[color]` and `$reset_color`

### Private Environment Variables

For sensitive environment variables (API keys, tokens, credentials), create a private file that won't be committed:

**File: `~/.private-env.zsh`** (git-ignored, lives outside this repo)

```zsh
# Private environment variables
export FOO=BAR

# Work-specific env vars
export COMPANY_API_KEY="xxxxxxxxxxxx"
```

This file is automatically sourced during shell initialization if it exists.

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

