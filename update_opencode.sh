#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="$(dirname "$0")/config/home-manager.nix"

echo "Fetching latest opencode version from GitHub..."
LATEST_VERSION=$(curl --silent https://api.github.com/repos/anomalyco/opencode/releases/latest | jq --raw-output '.tag_name' | sed 's/^v//')
URL="https://github.com/anomalyco/opencode/archive/refs/tags/v${LATEST_VERSION}.tar.gz"

echo "Calculating src hash..."
SRC_HASH=$(nix-prefetch-url --unpack "${URL}" | xargs nix hash convert --hash-algo sha256 --to sri)

echo "Latest version: $LATEST_VERSION"
echo "URL: $URL"
echo "Hash: $SRC_HASH"
echo ""

awk -v version="${LATEST_VERSION}" -v url="${URL}" -v hash="${SRC_HASH}" '
  /# OPENCODE_UPDATE_START/ {
    print "  # OPENCODE_UPDATE_START - Do not edit manually, use update_opencode.sh"
    print "  opencode-latest = pkgs.opencode.overrideAttrs (old: {"
    print "    version = \"" version "\";"
    print "    src = pkgs.fetchzip {"
    print "      url = \"" url "\";"
    print "      hash = \"" hash "\";"
    print "    };"
    print "  });"
    print "  # OPENCODE_UPDATE_END"
    skip = 1
    next
  }
  /# OPENCODE_UPDATE_END/ {
    skip = 0
    next
  }
  !skip
' "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

if ! git diff --quiet "${CONFIG_FILE}"; then
  git add "${CONFIG_FILE}"
  git commit --message "update opencode to ${LATEST_VERSION}"
  echo "Committed update to version ${LATEST_VERSION}"
else
  echo "No changes (already at version ${LATEST_VERSION})"
fi
