#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"
CONFIG_FILE="modules/voxtype.nix"

echo "Fetching latest voxtype release from GitHub..."
LATEST_VERSION=$(gh api repos/peteonrails/voxtype/releases/latest --jq '.tag_name' | sed 's/^v//')

echo "Fetching DMG checksum..."
DMG_SHA256=$(curl --fail --silent --show-error --location "https://github.com/peteonrails/voxtype/releases/download/v${LATEST_VERSION}/SHA256SUMS-macos.txt" | awk -v file="voxtype-${LATEST_VERSION}-macos-universal.dmg" '$2 == file { print $1 }')
DMG_HASH=$(nix hash convert --hash-algo sha256 --to sri "${DMG_SHA256}")

echo "Fetching source hash..."
SRC_HASH=$(nix flake prefetch "github:peteonrails/voxtype/v${LATEST_VERSION}" --json | jq --raw-output '.hash')

echo "Fetching git dependency hashes from upstream flake..."
export GIT_HASHES=$(gh api "repos/peteonrails/voxtype/contents/flake.nix?ref=v${LATEST_VERSION}" --jq '.content' | base64 --decode | awk '/outputHashes = \{/ { inside = 1; next } inside && /\};/ { exit } inside { sub(/^[ \t]+/, ""); print }')

echo "Latest version: $LATEST_VERSION"
echo ""

awk -v version="${LATEST_VERSION}" -v dmg="${DMG_HASH}" -v src="${SRC_HASH}" '
  /# VOXTYPE_UPDATE_START/ {
    print "  # VOXTYPE_UPDATE_START - Do not edit manually, use update_voxtype.sh"
    print "  voxtypeVersion = \"" version "\";"
    print "  voxtypeDmgHash = \"" dmg "\";"
    print "  voxtypeSrcHash = \"" src "\";"
    print "  voxtypeGitHashes = {"
    count = split(ENVIRON["GIT_HASHES"], lines, "\n")
    for (i = 1; i <= count; i++) if (lines[i] != "") print "    " lines[i]
    print "  };"
    print "  # VOXTYPE_UPDATE_END"
    skip = 1
    next
  }
  /# VOXTYPE_UPDATE_END/ {
    skip = 0
    next
  }
  !skip
' "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

if ! git diff --quiet HEAD -- "${CONFIG_FILE}"; then
  git add "${CONFIG_FILE}"
  git commit --message "update voxtype to ${LATEST_VERSION}" -- "${CONFIG_FILE}"
  echo "Committed update to version ${LATEST_VERSION}"
else
  echo "No changes (already at version ${LATEST_VERSION})"
fi
