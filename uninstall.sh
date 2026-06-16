#!/usr/bin/env bash
# Removes the symlink (only if it points to this repo).
# Does NOT delete TPM or plugin data — remove ~/.tmux/ manually if needed.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$REPO_DIR/.tmux.conf"
TARGET="$HOME/.tmux.conf"

if [[ -L "$TARGET" ]] && [[ "$(readlink "$TARGET")" == "$SOURCE" ]]; then
    rm "$TARGET"
    printf '\033[32m✓\033[0m Symlink removed: %s\n' "$TARGET"
    echo "  TPM and plugins kept at ~/.tmux/ — delete manually if desired."
else
    printf '\033[33m!\033[0m %s is not a symlink to this repo — nothing to do.\n' "$TARGET"
fi
