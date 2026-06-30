#!/bin/zsh

set -e

REPO_DIR=$(git rev-parse --show-toplevel)
CATEGORIES_DIR="$REPO_DIR/macOS"

# args: optional `--uninstall`/`-u` flag, then category names. defaults to `default` only.
# each category is a directory under macOS/ that may contain a Brewfile and/or
# setup.sh (run on install) and/or teardown.sh (run on uninstall).
ACTION=install
CATEGORIES=()
for arg in "$@"; do
    case "$arg" in
        -u|--uninstall) ACTION=uninstall ;;
        *) CATEGORIES+=("$arg") ;;
    esac
done
if [[ ${#CATEGORIES[@]} -eq 0 ]]; then
    CATEGORIES=(default)
fi

# install homebrew (skip on uninstall — no brew, nothing to remove)
if [[ "$ACTION" == install ]] && ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# extract `cask "name"` / `brew "name"` package names from a Brewfile, in file order.
brewfile_packages() {
    local file="$1" kind="$2"  # kind: cask | brew
    [[ -f "$file" ]] || return 0
    awk -v kind="$kind" '
        $1 == kind && match($0, /"[^"]+"/) {
            print substr($0, RSTART+1, RLENGTH-2)
        }
    ' "$file"
}

for category in "${CATEGORIES[@]}"; do
    echo "==> $ACTION category: $category"
    dir="$CATEGORIES_DIR/$category"
    brewfile="$dir/Brewfile"

    if [[ ! -d "$dir" ]]; then
        echo "no such category: $category (looked in $dir)" >&2
        exit 1
    fi

    if [[ "$ACTION" == install ]]; then
        # brew bundle is idempotent: skips anything already installed, taps included.
        [[ -f "$brewfile" ]] && brew bundle --file="$brewfile"
        [[ -x "$dir/setup.sh" ]] && "$dir/setup.sh"
    else
        # teardown runs first so it can clean up while packages still exist.
        [[ -x "$dir/teardown.sh" ]] && "$dir/teardown.sh"

        # `brew bundle cleanup` removes packages NOT in the file — wrong direction here.
        # uninstall everything the Brewfile declares, formulae before casks.
        for formula in $(brewfile_packages "$brewfile" brew); do
            brew list "$formula" &>/dev/null && brew uninstall "$formula"
        done

        for cask in $(brewfile_packages "$brewfile" cask); do
            brew list --cask "$cask" &>/dev/null && brew uninstall --cask "$cask"
        done
    fi
done
