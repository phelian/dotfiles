#!/usr/bin/env bash

set -euo pipefail

config_file="$(dirname "$0")/config/home-manager.nix"

version=$(curl --fail --silent --show-error 'https://opencode.ai/update/api/latest/cli/npm' | jq --exit-status --raw-output '.version')
url="https://registry.npmjs.org/@opencode/cli-darwin-arm64/-/cli-darwin-arm64-${version}.tgz"
hash=$(nix-prefetch-url --type sha256 "$url" | xargs nix hash convert --hash-algo sha256 --to sri)

awk -v version="$version" -v hash="$hash" '
  /# OPENCODE_UPDATE_START/ {
    print "  # OPENCODE_UPDATE_START - Do not edit manually, use update_opencode.sh"
    print "  opencodeVersion = \"" version "\";"
    print "  opencodeHash = \"" hash "\";"
    print "  opencode-latest = pkgs.stdenv.mkDerivation {"
    print "    pname = \"opencode\";"
    print "    version = opencodeVersion;"
    print "    src = pkgs.fetchurl {"
    print "      url = \"https://registry.npmjs.org/@opencode/cli-darwin-arm64/-/cli-darwin-arm64-${opencodeVersion}.tgz\";"
    print "      hash = opencodeHash;"
    print "    };"
    print "    unpackPhase = \047\047"
    print "      tar --extract --gzip --file \"$src\""
    print "    \047\047;"
    print "    installPhase = \047\047"
    print "      mkdir -p \"$out/bin\""
    print "      cp package/bin/opencode \"$out/bin/opencode\""
    print "      chmod +x \"$out/bin/opencode\""
    print "    \047\047;"
    print "    dontStrip = true;"
    print "  };"
    print "  # OPENCODE_UPDATE_END"
    skip = 1
    next
  }
  /# OPENCODE_UPDATE_END/ {
    skip = 0
    next
  }
  !skip
' "$config_file" > "${config_file}.tmp"
mv "${config_file}.tmp" "$config_file"
