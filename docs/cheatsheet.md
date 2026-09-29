# Terminal Cheat Sheet

Quick reference for the Alacritty, tmux, Zellij, and Vim workflow in this dotfiles repo.

## Alacritty

Config file:

```text
~/.config/alacritty/alacritty.toml
```

Repo source:

```text
config/alacritty/alacritty.toml
```

Local override:

```text
~/.config/alacritty/local.toml
```

### Behavior

| Setting | Value |
| --- | --- |
| Font | JetBrainsMono Nerd Font Mono, size 15 |
| Theme | Catppuccin Mocha colors |
| Background opacity | 1.0 |
| Window size | 220 x 52 cells |
| Padding | 12 px horizontal, 10 px vertical |
| Scrollback | 100000 lines |
| Copy on select | Enabled |
| Mouse hide while typing | Enabled |
| TERM | `xterm-256color` |

Alacritty intentionally does not provide native splits or tabs. Use tmux for sessions, windows, and panes.

### Useful Commands

| Command | Action |
| --- | --- |
| `alacritty -V` | Show Alacritty version |
| `alacritty --print-events` | Debug window/input events |
| `alacritty --config-file path/to/alacritty.toml` | Start with a specific config |
| `alacritty migrate` | Convert old YAML config to TOML |

### SSH And tmux

The config sets `TERM=xterm-256color`, which is widely available on remote Linux servers. This avoids custom terminal terminfo issues that can break tmux, clear-screen, vim, less, or man over SSH.

If a remote shell overrides `TERM`, reset it before starting tmux:

```bash
export TERM=xterm-256color
tmux attach -t session-name
```

### tmux Pairing

Use Alacritty as the terminal window and tmux for multiplexing:

```bash
tmux new -s work
```

For pane split shortcuts, see the tmux section below.

## tmux

Config file:

```text
~/.tmux.conf
```

Repo source:

```text
config/tmux/.tmux.conf
```

Local override:

```text
~/.tmux.local
```

### Prefix

| Key | Action |
| --- | --- |
| `Ctrl+a` | tmux prefix |
| `Ctrl+a Ctrl+a` | Send literal `Ctrl+a` to the shell/program |

### Sessions

| Command | Action |
| --- | --- |
| `tmux` | Start a new session |
| `tmux new -s name` | Start a named session |
| `tmux ls` | List sessions |
| `tmux attach -t name` | Attach to a session |
| `tmux kill-session -t name` | Kill a session |
| `Ctrl+a d` | Detach from current session |

### Windows

| Key | Action |
| --- | --- |
| `Ctrl+a c` | New window in current directory |
| `Ctrl+a n` | Next window |
| `Ctrl+a p` | Previous window |
| `Ctrl+a 1..9` | Jump to window number |
| `Ctrl+a ,` | Rename window |
| `Ctrl+a &` | Kill window |

Windows and panes start at index `1`, and windows are renumbered automatically.

### Panes

| Key | Action |
| --- | --- |
| `Ctrl+a \|` | Split pane right |
| `Ctrl+a -` | Split pane down |
| `Ctrl+a h` | Focus pane left |
| `Ctrl+a j` | Focus pane down |
| `Ctrl+a k` | Focus pane up |
| `Ctrl+a l` | Focus pane right |
| `Ctrl+a H` | Resize pane left by 5 |
| `Ctrl+a J` | Resize pane down by 5 |
| `Ctrl+a K` | Resize pane up by 5 |
| `Ctrl+a L` | Resize pane right by 5 |
| `Ctrl+a z` | Toggle pane zoom |
| `Ctrl+a x` | Kill pane |

Mouse selection, pane focus, and resizing are enabled.

### Copy Mode

| Key | Action |
| --- | --- |
| `Ctrl+a [` | Enter copy mode |
| `v` | Begin selection |
| `Ctrl+v` | Toggle rectangle selection |
| `y` | Copy selection and exit |
| `Escape` | Cancel copy mode |
| `/` | Search forward |
| `?` | Search backward |
| `n` | Next search match |
| `N` | Previous search match |

Copy mode uses vi keys.

### Config

| Key | Action |
| --- | --- |
| `Ctrl+a r` | Reload `~/.tmux.conf` |

## Zellij

Config file:

```text
~/.config/zellij/config.kdl
```

Repo source:

```text
config/zellij/config.kdl
```

### Behavior

| Setting | Value |
| --- | --- |
| Layout | `default`, with bottom shortcut hints |
| Theme | `dotfiles-mocha` |
| Pane frames | Enabled |
| Simplified UI | Enabled |
| Mouse mode | Enabled |
| Scrollback | 100000 lines |
| Copy on select | Enabled, to system clipboard |
| Session serialization | Enabled |
| Startup tips/release notes | Hidden |

### Useful Commands

| Command | Action |
| --- | --- |
| `zellij` | Start or attach using the default config |
| `zellij -s work` | Start or attach to a named session |
| `zellij list-sessions` | List sessions |
| `zellij attach work` | Attach to a named session |
| `zellij delete-session work` | Delete a named session |

### Daily Keys

| Key | Action |
| --- | --- |
| `Alt+h` / `Alt+Left` | Focus pane or tab left |
| `Alt+j` / `Alt+Down` | Focus pane down |
| `Alt+k` / `Alt+Up` | Focus pane up |
| `Alt+l` / `Alt+Right` | Focus pane or tab right |
| `Alt+n` | New pane |
| `Alt+f` | Toggle focused pane fullscreen |
| `Alt+[` | Previous tab |
| `Alt+]` | Next tab |

## Neovim

The active LazyVim configuration is deployed at `${XDG_CONFIG_HOME:-$HOME/.config}/nvim`. Press `Space` and pause for WhichKey discovery. See [Neovim Daily IDE Guide](neovim.md) for a progressive workflow.

### Modes

| Key | Action |
| --- | --- |
| `i` / `a` | Insert before / after cursor |
| `o` / `O` | Open a line below / above |
| `Esc` | Return to Normal mode |
| `v` / `V` / `Ctrl+v` | Character / line / block Visual mode |
| `:` | Command-line mode |

### Movement and Editing

| Key | Action |
| --- | --- |
| `h` `j` `k` `l` | Left, down, up, right |
| `w` / `b` / `e` | Next word / previous word / end of word |
| `0` / `^` / `$` | Line start / first non-blank / line end |
| `gg` / `G` | Top / bottom of file |
| `Ctrl+d` / `Ctrl+u` | Half-page down / up |
| `dd` / `yy` | Delete / yank line |
| `p` / `P` | Paste after / before cursor |
| `u` / `Ctrl+r` | Undo / redo |
| `.` | Repeat the last change |
| `ciw` / `diw` / `yiw` | Change / delete / yank inner word |
| `ci\"` / `di(` | Change inside quotes / delete inside parentheses |

### Search, Files, and Buffers

| Key or command | Action |
| --- | --- |
| `/text` / `?text` | Search forward / backward |
| `n` / `N` | Next / previous match |
| `:%s/old/new/gc` | Replace in file with confirmation |
| `<leader><space>` / `<leader>ff` | Find files |
| `<leader>/` | Search project text |
| `<leader>e` | Toggle explorer |
| `Shift+h` / `Shift+l` | Previous / next buffer |
| `<leader>bd` | Delete buffer |
| `:w` / `:q` / `:wq` | Save / quit / save and quit |

### Windows

| Key or command | Action |
| --- | --- |
| `:split` / `:vsplit` | Horizontal / vertical split |
| `Ctrl+h/j/k/l` | Focus the adjacent **Neovim window** |
| `Ctrl+w =` | Equalize Neovim windows |
| `Ctrl+w q` | Close the current Neovim window |

tmux and Zellij panes are outside Neovim. Use their pane bindings rather than `Ctrl+h/j/k/l` when focus is in another terminal pane.

### LSP, Diagnostics, and Formatting

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>xx` | Diagnostics panel |

### Git, Terminal, and Debugging

| Key | Action |
| --- | --- |
| `<leader>gg` | Open LazyGit |
| `<C-/>` | Toggle integrated terminal |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Start or continue debugging |
| `<leader>dO` | Step over |
| `<leader>di` | Step into |
