#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

echo "Updating codex-cli-nix flake input..."
nix flake update codex-cli-nix

VERSION=$(nix eval --raw --impure --expr "(builtins.getFlake (toString ./.)).inputs.codex-cli-nix.packages.aarch64-darwin.default.version")
LATEST_VERSION=$(curl --silent https://registry.npmjs.org/@openai/codex/latest | jq --raw-output '.version')

echo "Flake version: $VERSION"
echo "Upstream latest: $LATEST_VERSION"

if [[ "$VERSION" != "$LATEST_VERSION" ]]; then
  echo "WARNING: codex-cli-nix has not caught up with upstream yet"
fi

if ! git diff --quiet flake.lock; then
  git add flake.lock
  git commit --message "update codex to ${VERSION}"
  echo "Committed update to version ${VERSION}"
else
  echo "No changes (already at version ${VERSION})"
fi
