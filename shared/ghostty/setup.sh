#!/bin/bash

set -e

REPO_DIR=$(git rev-parse --show-toplevel)

# symlink ghostty config — repo is the source of truth, edits flow back through git.
# `-h` so a stale symlink is replaced; a regular file is moved aside as a backup once.
mkdir -p ~/.config/ghostty
target=~/.config/ghostty/config
source="$REPO_DIR/shared/ghostty/config"
if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.bak.$(date +%s)"
fi
ln -sfn "$source" "$target"
