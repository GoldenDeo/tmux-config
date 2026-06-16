#!/usr/bin/env bash
# Symlinks .tmux.conf from this repo into $HOME and bootstraps TPM.
# Idempotent — safe to re-run after pulls.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$REPO_DIR/.tmux.conf"
TARGET="$HOME/.tmux.conf"
TPM_DIR="$HOME/.tmux/plugins/tpm"

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
ok()    { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m!\033[0m %s\n' "$*"; }
info()  { printf '\033[36m→\033[0m %s\n' "$*"; }
die()   { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

[[ -f "$SOURCE" ]] || die "Source not found: $SOURCE"
command -v tmux >/dev/null 2>&1 || die "tmux not installed. Run: brew install tmux"

bold "Installing tmux config"
info "Repo:   $REPO_DIR"
info "Target: $TARGET"

# 1) Symlink .tmux.conf
if [[ -L "$TARGET" ]]; then
    current="$(readlink "$TARGET")"
    if [[ "$current" == "$SOURCE" ]]; then
        ok "Symlink already correct"
    else
        warn "Replacing existing symlink (was → $current)"
        ln -sfn "$SOURCE" "$TARGET"
        ok "Symlink updated"
    fi
elif [[ -e "$TARGET" ]]; then
    backup="$TARGET.bak.$(date +%Y%m%d-%H%M%S)"
    warn "Existing file found — backing up to $backup"
    mv "$TARGET" "$backup"
    ln -s "$SOURCE" "$TARGET"
    ok "Symlink created (old config kept at $backup)"
else
    ln -s "$SOURCE" "$TARGET"
    ok "Symlink created"
fi

# 2) TPM (Tmux Plugin Manager)
if [[ -d "$TPM_DIR/.git" ]]; then
    info "Updating TPM"
    git -C "$TPM_DIR" pull --ff-only --quiet || warn "TPM pull failed (offline?) — continuing"
    ok "TPM ready ($TPM_DIR)"
else
    info "Cloning TPM into $TPM_DIR"
    mkdir -p "$(dirname "$TPM_DIR")"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
    ok "TPM installed"
fi

# 3) Reload running tmux if any
if tmux info >/dev/null 2>&1; then
    tmux source-file "$TARGET"
    ok "Reloaded running tmux server"
else
    info "No tmux server running — nothing to reload"
fi

echo
bold "Done."
echo "Next steps:"
echo "  1. Start tmux:       tmux"
echo "  2. Install plugins:  press  Ctrl+Space  then  Shift+I  (capital I)"
echo "  3. Reload anytime:   Ctrl+Space  then  r"
