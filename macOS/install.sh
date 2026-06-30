#!/bin/zsh

set -e

REPO_DIR=$(git rev-parse --show-toplevel)
CONFIG="$REPO_DIR/macOS/install.yaml"

# args: category names to install. defaults to `default` only.
CATEGORIES=("$@")
if [[ ${#CATEGORIES[@]} -eq 0 ]]; then
    CATEGORIES=(default)
fi

if [[ ! -f "$CONFIG" ]]; then
    echo "config not found: $CONFIG" >&2
    exit 1
fi

# parse `<category>.<key>` (e.g. `default.casks`) — flat list under a 2-level nested key
yaml_list() {
    local category="$1" key="$2"
    awk -v cat="$category" -v key="$key" '
        # top-level category header: `default:` or `dev:`
        /^[A-Za-z_-]+:[[:space:]]*$/ {
            cur_cat = $0
            sub(/:.*$/, "", cur_cat)
            in_key = 0
            next
        }
        # second-level key under our category: `  casks:`
        cur_cat == cat && $0 ~ "^[[:space:]]+"key":" {
            in_key = 1
            # inline empty list: `casks: []`
            if ($0 ~ /\[[[:space:]]*\][[:space:]]*$/) in_key = 0
            next
        }
        # any other key at the same or shallower level closes our key
        in_key && /^[[:space:]]*[A-Za-z_-]+:/ && $0 !~ /^[[:space:]]*-/ {
            in_key = 0
        }
        in_key && /^[[:space:]]*-[[:space:]]*/ {
            sub(/^[[:space:]]*-[[:space:]]*/, "")
            sub(/[[:space:]]*#.*$/, "")
            sub(/[[:space:]]+$/, "")
            if (length($0)) print
        }
    ' "$CONFIG"
}

# install homebrew
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

for category in "${CATEGORIES[@]}"; do
    echo "==> category: $category"

    for cask in $(yaml_list "$category" casks); do
        if ! brew list --cask "${cask##*/}" &>/dev/null; then
            brew install --cask "$cask"
        fi
    done

    for formula in $(yaml_list "$category" formulae); do
        if ! brew list "${formula##*/}" &>/dev/null; then
            brew install "$formula"
        fi
    done

    for script in $(yaml_list "$category" scripts); do
        "$REPO_DIR/$script"
    done
done
