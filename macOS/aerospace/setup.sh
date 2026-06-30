#!/bin/zsh

set -e

REPO_DIR=$(git rev-parse --show-toplevel)

# copy aerospace config
cp -r "$REPO_DIR/macOS/aerospace/aerospace.toml" ~/.aerospace.toml

# launch aerospace
open -a Aerospace
