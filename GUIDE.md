# tmux — повний гайд

Шпаргалка та концепти для серйозного користування tmux: збереження сесій, шарінг, віддалене підключення, layout-presets, автоматизація довгих скриптів.

> Усі hotkey-комбінації нижче вважають префікс **`Ctrl+a`** (як налаштовано в `.tmux.conf` цього репо — screen-style, не конфліктує з macOS Ctrl+Space для перемикання мови). Дефолтний tmux префікс — `Ctrl+b`.

---

## Mental model

```
Server (один процес на машину)
└── Sessions (іменовані групи робочого простору)
    └── Windows (як «вкладки», нумеруються 1,2,3...)
        └── Panes (поділ вікна — splits)
```

**Ключове:** сесія живе всередині tmux-сервера, не в терміналі. Закриваєш термінал — сесія НЕ помирає. Перезавантажуєш машину — помирає (бо процес сервера здох). Для виживання між ребутами використовуй `tmux-resurrect/continuum` (уже увімкнено в конфізі).

---

## 1. Сесії

```bash
tmux new -s work              # створити іменовану
tmux ls                       # список усіх
tmux attach -t work           # приєднатись
tmux attach                   # до останньої
tmux kill-session -t work     # вбити сесію
tmux kill-server              # вбити все
```

Всередині tmux:

| Hotkey | Дія |
|---|---|
| `Prefix d` | detach — відключитись, сесія живе |
| `Prefix $` | перейменувати поточну сесію |
| `Prefix s` | вибрати сесію зі списку |
| `Prefix (` / `Prefix )` | попередня / наступна сесія |

### Multi-attach (одна сесія, кілька термінали)

```bash
# Термінал A:
tmux new -s shared
# Термінал B:
tmux attach -t shared   # бачите одне й те саме, синхронно — pair programming
```

За замовчуванням розмір другого attach зменшує розмір першого (worst-case fit). Якщо хочеш щоб кожен мав свій розмір:

```bash
tmux new-session -t shared -s shared-B   # окрема "view" на той самий контент
```

---

## 2. Збереження сесій між рестартами

Стандартно tmux втрачає все при ребуті. У нашому конфізі вже підключено:

- **tmux-resurrect** — ручне збереження `Prefix Ctrl+s` / restore `Prefix Ctrl+r`
- **tmux-continuum** — auto-save кожні 15 хв, auto-restore при tmux start

Зберігається: layout pane'ів, working directories, історія shell, **вміст pane'ів як скріншот**.

Для специфічних процесів (vim, nvim, ssh, mosh) — автоматично запускає їх знову при restore.

---

## 3. Шарінг сесії

### Локально, той самий юзер
Просто multi-attach (вище). Працює одразу.

### Локально між юзерами
```bash
# Юзер A створює:
tmux -S /tmp/shared new -s pair
chmod 777 /tmp/shared

# Юзер B приєднується:
tmux -S /tmp/shared attach -t pair
```

### Віддалено через інтернет
**[tmate](https://tmate.io/)** — fork tmux, який публікує сесію через relay-сервер. Інший пристрій підключається без жодних налаштувань:

```bash
brew install tmate
tmate
# показує дві URL: read-only і read-write ssh-команди
# даєш другу URL — він підключається
```

Це окремий процес, не звичайний tmux — для шарінга на ходу.

---

## 4. Віддалене підключення з іншого пристрою

Класичний шлях — **SSH + tmux** на сервері:

```bash
ssh you@server
tmux new -s work
# роби довгу роботу...
# Prefix d → detach, exit ssh

# З будь-якого пристрою:
ssh you@server
tmux attach -t work    # все на місці
```

Killer-feature: **mosh** замість ssh — стійкий до зміни мережі (wifi → 4G не рве):

```bash
brew install mosh
mosh you@server -- tmux attach -t work
```

З iPhone — додатки **Blink Shell** або **Termius** мають вбудовану mosh-підтримку.

---

## 5. Windows (вкладки)

| Hotkey | Дія |
|---|---|
| `Prefix c` | створити нове вікно |
| `Prefix ,` | перейменувати поточне |
| `Prefix &` | закрити поточне (з підтвердженням) |
| `Prefix n` / `Prefix p` | наступне / попереднє |
| `Prefix 1..9` | стрибнути до вікна за номером |
| `Prefix w` | інтерактивний список вікон |
| `Prefix f` | пошук по тексту в усіх вікнах |
| `Prefix .` | пересунути вікно на інший номер |
| `Prefix !` | витягнути pane у нове окреме вікно |
| `Prefix g` | приєднати поточний pane до наявного вікна (спитає номер) |

---

## 6. Panes (split-екрани)

### Створення і навігація

| Hotkey | Дія |
|---|---|
| `Prefix \|` | split вертикально (left/right) — кастомізований |
| `Prefix -` | split горизонтально (top/bottom) — кастомізований |
| `Prefix o` | наступний pane |
| `Prefix h/j/k/l` | навігація vim-style |
| `Prefix ↑↓←→` | навігація стрілками |
| `Prefix x` | закрити pane |
| `Prefix z` | zoom — pane на весь екран (toggle) |
| `Prefix q` | показати номери pane (натисни цифру щоб стрибнути) |
| `Prefix {` / `Prefix }` | swap pane вліво / вправо |
| `Prefix !` | витягнути pane у нове вікно |

### Resize

| Hotkey | Дія |
|---|---|
| `Prefix H/J/K/L` | resize на 3-5 cells у напрямку (vim-style, repeat-mode) |
| `Prefix Ctrl+↑↓←→` | дрібний resize по 1 cell |
| `Prefix : resize-pane -D 10` | точно (down 10 рядків) |

### Layouts (presets розкладок)

| Hotkey | Layout |
|---|---|
| `Prefix Alt+1` | `even-horizontal` — всі в одному ряду |
| `Prefix Alt+2` | `even-vertical` — всі в одній колонці |
| `Prefix Alt+3` | `main-horizontal` — один великий зверху, решта внизу |
| `Prefix Alt+4` | `main-vertical` — один великий зліва, решта справа |
| `Prefix Alt+5` | `tiled` — мозаїка приблизно рівних квадратів |
| `Prefix Space` | циклічний перебір layouts |

---

## 7. Пресети сесій (session managers)

Один скрипт описує всю робочу конфігурацію — запускаєш одну команду, маєш готову сесію з вікнами, pane'ами, відкритими процесами в потрібних директоріях.

### Tmuxinator (Ruby)

```bash
brew install tmuxinator
tmuxinator new story-tail
```

Відкриває YAML:

```yaml
name: story-tail
root: ~/PhpstormProjects/story-tail/

windows:
  - editor:
      layout: main-vertical
      panes:
        - nvim
        - git status
  - backend:
      root: project
      panes:
        - make up
        - make shell
  - flutter:
      root: app
      panes:
        - make run
        - flutter analyze --watch
```

Запуск: `tmuxinator start story-tail` — готова сесія з 3 вікнами, кожне зі своїми pane і запущеними командами.

### Tmuxp (Python — той самий концепт, JSON/YAML)

```bash
pip install tmuxp
tmuxp load story-tail.yaml
```

### Просто bash-скрипт (без залежностей)

```bash
#!/bin/bash
SESSION=story-tail
cd ~/PhpstormProjects/story-tail

tmux new-session -d -s $SESSION -n editor
tmux send-keys -t $SESSION:editor 'nvim' C-m

tmux new-window -t $SESSION -n backend -c "$(pwd)/project"
tmux send-keys -t $SESSION:backend 'make up' C-m

tmux split-window -t $SESSION:backend -h
tmux send-keys -t $SESSION:backend.1 'make shell' C-m

tmux new-window -t $SESSION -n flutter -c "$(pwd)/app"
tmux send-keys -t $SESSION:flutter 'make run' C-m

tmux attach -t $SESSION
```

Зберігаєш як `~/bin/storytail-tmux`, `chmod +x`, далі лише `storytail-tmux`.

---

## 8. Довгі скрипти / автоматизація

### Запуск і detach

```bash
tmux new -d -s longjob 'make full-test'   # запуск у фоні, не attach
tmux attach -t longjob                     # подивитись прогрес коли захочеш
```

Скрипт тримається живим у tmux, навіть якщо вилогінився з SSH.

### Логування виводу в файл

```bash
tmux pipe-pane -o 'cat >> ~/logs/build.log'
# усе що з'являється в pane також пишеться у файл
# повторне виконання — toggle off
```

### Відправка команд у pane ззовні

```bash
tmux send-keys -t work:0.0 'phpunit tests/' Enter
# можна писати скрипти, які «друкують» команди в інший pane
```

### Capture виводу

```bash
tmux capture-pane -t work:0.0 -p              # вивести stdout pane
tmux capture-pane -t work:0.0 -p -S -1000     # останні 1000 рядків
tmux capture-pane -t work:0.0 -p > out.txt
```

### Синхронний ввід у кілька pane (multi-host)

```
Prefix : setw synchronize-panes on
```

Все що друкуєш — летить одночасно в усі pane вікна. Корисно коли ssh-аєшся на 5 серверів і хочеш зробити те саме скрізь.

### Notify по завершенню (macOS)

```bash
tmux new -d -s build 'make full-test; osascript -e "display notification \"Build done\""'
```

---

## 9. Copy-mode

Увійти в copy-mode: **`Prefix [`**. У нашому конфізі — vi-keys (`set -g mode-keys vi`).

| Hotkey (у copy-mode) | Дія |
|---|---|
| `h/j/k/l` | рух |
| `w` / `b` | слово вперед / назад |
| `g` / `G` | початок / кінець буфера |
| `/` / `?` | пошук вперед / назад |
| `v` | почати виділення |
| `y` | копіювати виділене в системний clipboard (через pbcopy) |
| `q` | вийти |

Paste назад у термінал: **`Prefix ]`**.

---

## 10. Reload конфіга

Після edits у `~/.tmux.conf` — без рестарту tmux:

```
Prefix r
```

Або з shell:

```bash
tmux source-file ~/.tmux.conf
```

---

## 11. Корисні команди-довідки

```bash
tmux list-keys                 # усі активні біндинги
tmux list-commands             # усі команди
tmux show-options -g           # глобальні опції
tmux show-window-options -g    # window options
tmux info                      # стан сервера
```

Всередині tmux: `Prefix ?` — показати всі біндинги (поточні).

---

## Що НЕ покрите цим гайдом

- **tmux scripting** на серйозному рівні (`#{format}`-вирази, `if-shell`, custom widgets у status bar) — це окрема глибока тема, читай `man tmux` секцію FORMATS.
- **Powerline / Nerd Font glyphs у status bar** — для них потрібен patched font і додатковий конфіг. Не ставив за замовчуванням, бо ламається без правильного шрифту.
- **Hooks** (`set-hook -g session-created ...`) — можна автоматично виконувати команди на події. Корисно для специфічних workflow.

---

## Корисні посилання

- [tmux man page](https://man.openbsd.org/tmux)
- [tmux GitHub](https://github.com/tmux/tmux/wiki) — офіційна wiki
- [TPM](https://github.com/tmux-plugins/tpm) — plugin manager
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)
- [tmate](https://tmate.io/) — instant terminal sharing
- [Tmuxinator](https://github.com/tmuxinator/tmuxinator)
- [Awesome tmux](https://github.com/rothgar/awesome-tmux) — collections of plugins, themes, scripts
