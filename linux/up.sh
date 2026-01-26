#!/bin/bash

set -e

REPO_DIR=$(git rev-parse --show-toplevel)

cp -r $REPO_DIR/linux/config/* $HOME/.config/

# copy ghostty config
mkdir -p $HOME/.config/ghostty
cp $REPO_DIR/linux/ghostty/config $HOME/.config/ghostty/config

