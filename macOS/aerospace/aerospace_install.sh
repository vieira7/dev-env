#!/bin/zsh

set -e

REPO_DIR=$(git rev-parse --show-toplevel)

# install aerospace
if ! brew list --cask aerospace &>/dev/null; then
    brew install --cask nikitabobko/tap/aerospace
fi

# install borders
if ! brew list borders &>/dev/null; then
    brew tap FelixKratz/formulae
    brew install borders
fi

# copy aerospace config
cp -r $REPO_DIR/macOS/aerospace/aerospace.toml ~/.aerospace.toml

# launch aerospace
open -a Aerospace
