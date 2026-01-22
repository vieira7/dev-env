#!/bin/bash

set -e

REPO_DIR=$(git rev-parse --show-toplevel)

cp -r $REPO_DIR/linux/config/* $HOME/.config/
