#!/bin/zsh

set -e

REPO_DIR=$(git rev-parse --show-toplevel)

# symlink aerospace config — repo is the source of truth, edits flow back through git.
# `-h` so a stale symlink is replaced; a regular file is moved aside as a backup once.
target=~/.aerospace.toml
source="$REPO_DIR/macOS/aerospace/aerospace.toml"
if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.bak.$(date +%s)"
fi
ln -sfn "$source" "$target"

# launch aerospace
open -a Aerospace
