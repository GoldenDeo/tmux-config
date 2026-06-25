#!/usr/bin/env bash
# Tmux session preset template. Copy this file, rename, and adapt.
# Filename (without .sh) becomes the launch command: tmx-<name>.
# Files starting with `_` are skipped by install.sh.

set -euo pipefail

SESSION="rename-me"
ROOT="$HOME/path/to/project"

# Re-attach if already running
if tmux has-session -t "$SESSION" 2>/dev/null; then
    exec tmux attach -t "$SESSION"
fi

# First window — created with new-session
tmux new-session -d -s "$SESSION" -n main -c "$ROOT"
# tmux send-keys -t "$SESSION:main" 'your-startup-command' C-m

# Add splits inside a window:
# tmux split-window -t "$SESSION:main" -v -c "$ROOT/subdir"   # -v = horizontal divider
# tmux split-window -t "$SESSION:main" -h -c "$ROOT/subdir"   # -h = vertical divider

# Add more windows:
# tmux new-window -t "$SESSION" -n second -c "$ROOT/other"
# tmux send-keys -t "$SESSION:second" 'another-command' C-m

# Default to the first window when attaching
tmux select-window -t "$SESSION:main"
exec tmux attach -t "$SESSION"
