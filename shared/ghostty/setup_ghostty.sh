#!/bin/bash

set -e

REPO_DIR=$(git rev-parse --show-toplevel)

mkdir -p ~/.config/ghostty
cp -r $REPO_DIR/shared/ghostty/config ~/.config/ghostty/config
