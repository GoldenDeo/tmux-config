# Terminal cheat sheet

Quick reference for the productivity features added on top of plain tmux + WezTerm.
tmux prefix is **`Ctrl+a`**. WezTerm `Cmd` = the macOS Command key.

> Install / re-install everything: `./install.sh` (or just the extras:
> `scripts/install-deps.sh`). Both are idempotent.

---

## 1. Project sessionizer (fzf) — the big one

Fuzzy-jump to any of your `~/PhpstormProjects` projects, each in its own tmux
session. Creates the session if it doesn't exist, switches to it if it does.

| Key | Where | What |
|-----|-------|------|
| `Ctrl+a` then `f` | tmux | Open the project picker in a popup |
| `Cmd+o`           | WezTerm | Same picker (forwards `prefix f`) |
| `tmux-sessionizer` | shell | Run from the command line |
| `tmux-sessionizer ~/path` | shell | Jump straight to a session for a path |

Inside the picker: type to filter, `Enter` to open, `Esc` to cancel.
Add more project roots by editing `SEARCH_ROOTS` in `scripts/tmux-sessionizer`.

---

## 2. zoxide — smart `cd`

Learns the directories you visit most, so you jump with a fragment of the name.

| Command | What |
|---------|------|
| `z tmux`  | cd to the best match for "tmux" (e.g. `~/PhpstormProjects/tmux-config`) |
| `z proj api` | match on multiple fragments |
| `zi`      | interactive pick (via fzf) |

The more you use it, the better it ranks. Plain `cd` still works as always.

---

## 3. fzf key bindings (shell)

Installed with fzf's zsh integration:

| Key | What |
|-----|------|
| `Ctrl+r` | Fuzzy-search command history |
| `Ctrl+t` | Fuzzy-pick a file/path, insert it into the command line |
| `Alt+c`  | Fuzzy-pick a subdirectory and `cd` into it |

---

## 4. Prompt navigation (jump between commands)

Powered by OSC 133 prompt marks emitted by the shell.

| Key | Where | What |
|-----|-------|------|
| `Cmd+↑` / `Cmd+↓` | WezTerm | Scroll to previous / next prompt |
| `{` / `}` | tmux copy-mode | Jump to previous / next prompt |

**Caveat:** WezTerm's `Cmd+↑/↓` only works in tabs **not** running tmux (tmux
owns the screen). Inside tmux use copy-mode: `Ctrl+a [` to enter, then `{` / `}`.

---

## 5. tmux quality-of-life

| Key (after `Ctrl+a`) | What |
|----------------------|------|
| `e`     | Toggle **sync mode** — type into all panes at once (shows ON/OFF) |
| `C-l`   | Clear screen **and** scrollback history |
| `E`     | Dump the current pane's scrollback into `$EDITOR` (new window) |

(`Ctrl+l` alone is pane-navigation "move right", hence `prefix C-l` for clear.)

---

## What lives where

| Thing | File |
|-------|------|
| tmux keybindings & options | `.tmux.conf` |
| Sessionizer script | `scripts/tmux-sessionizer` |
| Shell integration (fzf, zoxide, OSC 133, `$EDITOR`) | `scripts/shell-integration.zsh` |
| Dependency installer | `scripts/install-deps.sh` |
| WezTerm keybindings (`Cmd+o`, `Cmd+↑/↓`) | `~/PhpstormProjects/wezterm-config/config/bindings.lua` |

`~/.zshrc` just sources `scripts/shell-integration.zsh` between the
`# >>> tmux-config shell integration >>>` markers — edit the repo file, not zshrc.
