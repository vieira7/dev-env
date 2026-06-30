#!/bin/zsh

set -e

REPO_DIR=$(git rev-parse --show-toplevel)

# compose shared assets used by macOS's default category.
"$REPO_DIR/shared/ghostty/setup.sh"
