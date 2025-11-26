#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="$(dirname "$0")/config/home-manager.nix"

echo "Fetching latest claude-code version from npm..."
LATEST_VERSION=$(curl --silent https://registry.npmjs.org/@anthropic-ai/claude-code | jq --raw-output '."dist-tags".latest')
URL="https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${LATEST_VERSION}.tgz"

echo "Calculating src hash..."
SRC_HASH=$(nix-prefetch-url --unpack "${URL}" | xargs nix hash convert --hash-algo sha256 --to sri)

echo "Latest version: $LATEST_VERSION"
echo "URL: $URL"
echo "Hash: $SRC_HASH"
echo ""

awk -v version="${LATEST_VERSION}" -v url="${URL}" -v hash="${SRC_HASH}" '
  /# AUTO_UPDATE_START/ {
    print "  # AUTO_UPDATE_START - Do not edit manually, use update-claude-code.sh"
    print "  claude-code-latest = pkgs.claude-code.overrideAttrs (old: {"
    print "    version = \"" version "\";"
    print "    src = pkgs.fetchzip {"
    print "      url = \"" url "\";"
    print "      hash = \"" hash "\";"
    print "    };"
    print "  });"
    print "  # AUTO_UPDATE_END"
    skip = 1
    next
  }
  /# AUTO_UPDATE_END/ {
    skip = 0
    next
  }
  !skip
' "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

echo "Updated ${CONFIG_FILE}"
