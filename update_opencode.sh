#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="$(dirname "$0")/config/home-manager.nix"

echo "Fetching latest opencode version from GitHub..."
LATEST_VERSION=$(curl --silent https://api.github.com/repos/anomalyco/opencode/releases/latest | jq --raw-output '.tag_name' | sed 's/^v//')

echo "Calculating src hash..."
SRC_HASH=$(nix-prefetch-url --unpack "https://github.com/anomalyco/opencode/archive/refs/tags/v${LATEST_VERSION}.tar.gz" 2>/dev/null | xargs nix hash convert --hash-algo sha256 --to sri)

echo "Latest version: $LATEST_VERSION"
echo "Src hash: $SRC_HASH"
echo ""

echo "Computing node_modules hash (this may take a while)..."
echo "Building with placeholder hash to get the correct one..."

# Create a temporary flake to compute the node_modules hash
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

cat > "$TEMP_DIR/flake.nix" << EOF
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      src = pkgs.fetchFromGitHub {
        owner = "anomalyco";
        repo = "opencode";
        tag = "v${LATEST_VERSION}";
        hash = "${SRC_HASH}";
      };
    in {
      packages.aarch64-darwin.node_modules = pkgs.opencode.node_modules.overrideAttrs {
        version = "${LATEST_VERSION}";
        inherit src;
        outputHash = pkgs.lib.fakeHash;
      };
    };
}
EOF

# Try to build and capture the hash from the error
NODE_MODULES_HASH=$(nix build "$TEMP_DIR#node_modules" 2>&1 | grep -oE 'got:[[:space:]]+sha256-[A-Za-z0-9+/=]+' | sed 's/got:[[:space:]]*//' || true)

if [[ -z "$NODE_MODULES_HASH" ]]; then
  echo "ERROR: Could not compute node_modules hash automatically."
  echo "Run 'just switch' and copy the hash from the error message."
  exit 1
fi

echo "Node modules hash: $NODE_MODULES_HASH"
echo ""

awk -v version="${LATEST_VERSION}" -v srcHash="${SRC_HASH}" -v nodeModulesHash="${NODE_MODULES_HASH}" '
  /# OPENCODE_UPDATE_START/ {
    print "  # OPENCODE_UPDATE_START - Do not edit manually, use update_opencode.sh"
    print "  opencodeVersion = \"" version "\";"
    print "  opencodeSrcHash = \"" srcHash "\";"
    print "  opencodeNodeModulesHash = \"" nodeModulesHash "\";"
    print "  opencodeSrc = pkgs.fetchFromGitHub {"
    print "    owner = \"anomalyco\";"
    print "    repo = \"opencode\";"
    print "    tag = \"v${opencodeVersion}\";"
    print "    hash = opencodeSrcHash;"
    print "  };"
    print "  opencode-latest = pkgs.opencode.overrideAttrs (final: old: {"
    print "    version = opencodeVersion;"
    print "    src = opencodeSrc;"
    print "    passthru ="
    print "      old.passthru"
    print "      // {"
    print "        node_modules = old.passthru.node_modules.overrideAttrs {"
    print "          outputHash = opencodeNodeModulesHash;"
    print "        };"
    print "      };"
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
