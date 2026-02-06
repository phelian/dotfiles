# Agent Instructions

This repository contains nix-darwin and home-manager configuration for macOS.

## Project Overview

- **Type**: nix-darwin + home-manager dotfiles
- **Platform**: macOS (aarch64-darwin / Apple Silicon)
- **Primary Language**: Nix
- **Shell**: zsh with oh-my-zsh
- **Hostname**: sculpin
- **Username**: felix

## Build/Test/Lint Commands

### Available Commands (from devShell)

After entering the devShell with `direnv allow` or `nix develop`:

```bash
build       # build config and show diff against current generation (uses nvd)
switch      # apply configuration with darwin-rebuild switch
update      # update flake inputs with commit
post-switch # post-activation macOS settings (scroll direction, etc.)
```

### Using Just

```bash
just switch  # runs sudo switch followed by post-switch
```

### Formatting

```bash
nix fmt      # format Nix files using alejandra
```

### First-Time Installation

```bash
nix build .#darwinConfigurations.sculpin.system --extra-experimental-features 'nix-command flakes'
./result/sw/bin/darwin-rebuild switch --flake .#sculpin
direnv allow
```

## Directory Structure

```
.
├── .claude/              # claude code configuration
│   ├── CLAUDE.md         # main instructions
│   ├── settings.json     # permissions
│   ├── agents/           # agent definitions
│   ├── commands/         # custom commands
│   └── skills/           # skill definitions
├── config/               # user configuration
│   ├── home-manager.nix  # main home-manager entry point
│   ├── homebrew.nix      # homebrew casks
│   └── oh-my-zsh/        # zsh theme and customization
├── modules/              # nix modules
│   ├── apps.nix          # system packages + homebrew import
│   ├── host-users.nix    # host/user configuration
│   ├── nix-core.nix      # nix settings
│   ├── system.nix        # macOS system defaults
│   └── home-manager/     # home-manager program modules
├── flake.nix             # main flake entry point
├── flake.lock
├── justfile
└── README.md
```

## Code Style Guidelines

### Nix

- Use 2-space indentation
- No trailing semicolons after closing braces (except inside attribute sets)
- Simple module pattern: `{ pkgs, ... }: { ... }`
- Use `let ... in` blocks for local variables
- Use `with pkgs;` pattern for package lists
- Relative imports with `../` notation
- Minimal comments unless necessary for reference URLs
- Format with `alejandra` (run `nix fmt`)

Example module structure:
```nix
{ pkgs, ... }:
{
  programs.example = {
    enable = true;
    settings = {
      option = "value";
    };
  };
}
```

### Shell Scripts

- Start with `set -euo pipefail`
- Use long-form flags (e.g., `--recursive` not `-r`)
- Use `$(...)` for command substitution
- Lowercase variable names with underscores
- Prefer `rg` over `grep`

### Git Commit Messages

- Single-line summaries in lowercase (except proper names)
- No compound sentences
- No conventional commit prefixes (no `feat:`, `fix:`, etc.)
- No footers, co-authored-by lines, or AI mentions
- Files must end with a newline

Good examples:
```
add opencode and gsd package source
update zsh theme colors
fix atuin sync configuration
```

Bad examples:
```
feat: Add new feature
Fixed the bug and updated tests
Add feature

Co-authored-by: ...
```

### TypeScript (for scripting)

- Use Deno for general scripting
- Avoid `any` and `let` keywords
- Don't use `function`, `interface`, or `class` keywords
- Rely on type inference; avoid explicit return types unless necessary

### YAML

- Use double quotes for strings

### SQL

- Use lowercase unless existing code uses different casing

## Package Management Approach

- **System packages**: `environment.systemPackages` in `modules/apps.nix`
- **User packages**: `home.packages` in `config/home-manager.nix`
- **GUI apps**: Homebrew casks in `config/homebrew.nix`
- **Per-program config**: Individual modules in `modules/home-manager/`

devtools are intentionally excluded from this repo - they should be installed per-project via direnv.

## Key Conventions

- Touch ID enabled for sudo
- Git: ff-only merges, simple push, autosquash rebase
- Rose Pine color theme for terminal tools
- Default editor: vim

## Flake Inputs

- nixpkgs: nixos-unstable
- darwin: nix-darwin
- home-manager: follows darwin
- flake-utils

## Adding New Packages

1. For CLI tools: add to `home.packages` in `config/home-manager.nix`
2. For GUI apps: add to `casks` in `config/homebrew.nix`
3. For programs with configuration: create a module in `modules/home-manager/`

## Common Tasks

### Add a new home-manager module

1. Create `modules/home-manager/<name>.nix`:
```nix
{ pkgs, ... }:
{
  programs.<name> = {
    enable = true;
  };
}
```
2. Import it in `config/home-manager.nix`

### Test changes before applying

```bash
build  # shows diff without applying
switch # applies changes
```
