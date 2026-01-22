---
name: nix-add-app
description: "Add packages to Nix flake devShells. Use when a command or tool is not found, a dependency is missing, or a package needs to be added to make code work."
---

# Nix Add Application

## When to use

- A command or tool is not found
- A dependency is missing for a project
- The user asks to add a package or tool
- You determine a tool is needed to complete a task

## Instructions

1. **Check for flake.nix and .envrc** in the current working directory.

2. **If flake.nix exists:**
   - Read the `flake.nix` to understand its devShell structure
   - Search nixpkgs for the package: `nix search nixpkgs#<name>`
   - Add the package to the devShell (usually in `buildInputs` or `packages`)
   - Preserve the existing structure and style
   - Remind the user to run `direnv reload` or re-enter the directory

3. **If no flake.nix exists:**
   - Ask the user if a flake.nix should be created
   - If yes, create a minimal flake with a devShell containing the requested package
   - Also create `.envrc` with `use flake` if it doesn't exist
   - Add `.direnv` to `.gitignore` if not already present

## Minimal flake template

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # packages here
          ];
        };
      });
}
```
