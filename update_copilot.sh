#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="$(dirname "$0")/config/home-manager.nix"

echo "Fetching latest copilot version from npm..."
LATEST_VERSION=$(curl --silent https://registry.npmjs.org/@github/copilot/latest | jq --raw-output '.version')

echo "Calculating hash..."
HASH=$(nix-prefetch-url "https://registry.npmjs.org/@github/copilot-darwin-arm64/-/copilot-darwin-arm64-${LATEST_VERSION}.tgz" 2>/dev/null | xargs nix hash convert --hash-algo sha256 --to sri)

echo "Latest version: $LATEST_VERSION"
echo "Hash: $HASH"
echo ""

awk -v version="${LATEST_VERSION}" -v hash="${HASH}" '
  /# COPILOT_UPDATE_START/ {
    print "  # COPILOT_UPDATE_START - Do not edit manually, use update_copilot.sh"
    print "  copilotVersion = \"" version "\";"
    print "  copilotHash = \"" hash "\";"
    print "  # COPILOT_UPDATE_END"
    skip = 1
    next
  }
  /# COPILOT_UPDATE_END/ {
    skip = 0
    next
  }
  !skip
' "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

if ! git diff --quiet "${CONFIG_FILE}"; then
  git add "${CONFIG_FILE}"
  git commit --message "update copilot to ${LATEST_VERSION}"
  echo "Committed update to version ${LATEST_VERSION}"
else
  echo "No changes (already at version ${LATEST_VERSION})"
fi
