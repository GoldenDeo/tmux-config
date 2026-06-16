# tmux-config

Власний `.tmux.conf` із Lake-палітрою (matches Story Tail design tokens), TPM-плагінами і sensible defaults. Префікс — `Ctrl+Space`.

## Встановлення

```bash
git clone <repo> ~/PhpstormProjects/tmux-config
cd ~/PhpstormProjects/tmux-config
./install.sh
```

Скрипт:
1. Симлінкує `.tmux.conf` → `~/.tmux.conf` (бекапить існуючий, якщо є).
2. Клонує TPM у `~/.tmux/plugins/tpm`.
3. Релоудить запущений tmux-сервер (якщо є).

Запусти `tmux`, далі **`Ctrl+Space`** потім **`Shift+I`** (велика I) — TPM скачає плагіни.

## Видалення

```bash
./uninstall.sh   # знімає симлінк; TPM-плагіни лишає (видали ~/.tmux/ якщо хочеш)
```

## Що всередині

- **`.tmux.conf`** — конфіг (true color, mouse, vim-style, Lake-theme status bar, TPM-плагіни)
- **`install.sh`** / **`uninstall.sh`** — idempotent bootstrap
- **[`GUIDE.md`](GUIDE.md)** — повна шпаргалка: сесії, шарінг, віддалене підключення, layouts, presets, автоматизація

## Плагіни (через TPM)

- `tmux-sensible` — sane defaults
- `tmux-resurrect` + `tmux-continuum` — auto-save/restore сесій між ребутами
- `tmux-yank` — copy у системний clipboard
- `tmux-fzf` — fuzzy search sessions/windows

## Ключові hotkey

| Hotkey | Дія |
|---|---|
| `Ctrl+Space \|` | split вертикально |
| `Ctrl+Space -` | split горизонтально |
| `Ctrl+Space h/j/k/l` | навігація між pane (vim) |
| `Ctrl+Space H/J/K/L` | resize pane |
| `Ctrl+Space r` | reload конфіга |
| `Ctrl+Space d` | detach (сесія живе) |
| `Ctrl+Space Ctrl+s` | manual save (resurrect) |
| `Ctrl+Space Ctrl+r` | manual restore (resurrect) |

Повний список — у [GUIDE.md](GUIDE.md).
