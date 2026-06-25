#!/usr/bin/env bash
# Story Tail dev session.
# Windows: editor · backend (make up + shell) · flutter (make run + shell) · claude
set -euo pipefail

SESSION="story-tail"
ROOT="$HOME/PhpstormProjects/story-tail"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    exec tmux attach -t "$SESSION"
fi

# 1) editor — empty shell at project root
tmux new-session -d -s "$SESSION" -n editor -c "$ROOT"

# 2) backend — top: make up (docker), bottom: shell in project/ (for `make shell` etc.)
tmux new-window -t "$SESSION" -n backend -c "$ROOT/project"
tmux send-keys  -t "$SESSION:backend" 'make up' C-m
tmux split-window -t "$SESSION:backend" -v -c "$ROOT/project"

# 3) flutter — top: make run, bottom: shell in app/ (for `make analyze`, `flutter test` etc.)
tmux new-window -t "$SESSION" -n flutter -c "$ROOT/app"
tmux send-keys  -t "$SESSION:flutter" 'make run' C-m
tmux split-window -t "$SESSION:flutter" -v -c "$ROOT/app"

# 4) claude — Claude Code lead session
tmux new-window -t "$SESSION" -n claude -c "$ROOT"
tmux send-keys  -t "$SESSION:claude" 'claude' C-m

tmux select-window -t "$SESSION:editor"
exec tmux attach -t "$SESSION"
