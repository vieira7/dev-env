#!/bin/zsh

set -e

REPO_DIR=$(git rev-parse --show-toplevel)

# install aerospace
if ! brew list --cask aerospace &>/dev/null; then
    brew install --cask aerospace
fi

# copy aerospace config
cp -r $REPO_DIR/macOS/aerospace/aerospace.toml ~/.aerospace.toml

# reload aerospace
aerospace reload-config
