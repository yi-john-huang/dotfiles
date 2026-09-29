# Neovim Daily IDE Guide

This repository deploys a LazyVim-based Neovim setup for TypeScript/JavaScript, Python, Go, Java, Bash, Lua, JSON, YAML, TOML, Markdown, Terraform, and Docker files.

## Install and First Launch

Run the bootstrap, restart the shell, and open a project directory:

```bash
./bootstrap.sh
exec "$SHELL"
cd path/to/project
nvim .
```

The bootstrap links `config/nvim/` to `${XDG_CONFIG_HOME:-$HOME/.config}/nvim`. The first Neovim launch needs network access: lazy.nvim downloads locked plugins and Mason downloads language servers, formatters, linters, and debug adapters. Let those jobs finish before judging missing IDE features.

Press `Space` and pause. WhichKey displays available leader commands and is the safest way to discover the configuration.

## The Editing Model

Neovim is modal:

- **Normal mode** is for navigation and commands. Press `Esc` to return here.
- **Insert mode** enters text. Use `i`, `a`, `o`, or `O` from Normal mode.
- **Visual mode** selects text. Use `v`, `V`, or `Ctrl-v`.
- **Command-line mode** runs commands after `:`.

Normal-mode editing combines an operator, an optional count, and a motion or text object:

- `dw`: delete to the next word.
- `3dd`: delete three lines.
- `ciw`: change the inner word.
- `di"`: delete inside double quotes.
- `yap`: yank a paragraph.
- `.`: repeat the last change.

Learn a small vocabulary first: `h j k l`, `w b e`, `0 ^ $`, `gg G`, `f{char}`, and text objects such as `iw`, `i"`, `i(`, and `ap`.

## Buffers, Windows, and Tabs

- A **buffer** is an open file or editable document. It may exist without being visible.
- A **window** is a viewport showing a buffer. Splits create more windows.
- A **tab page** is a layout of windows, not a file container.

Use `Shift-h` and `Shift-l` for previous and next buffers. Use `<leader>bd` to delete a buffer. Use `<C-h>`, `<C-j>`, `<C-k>`, and `<C-l>` to move between Neovim windows. Those keys operate inside Neovim; tmux and Zellij pane navigation remains controlled by their own bindings.

## VS Code Tasks in Neovim

| VS Code task | Neovim action |
| --- | --- |
| Open Explorer | `<leader>e` |
| Quick Open / find files | `<leader><space>` or `<leader>ff` |
| Search workspace text | `<leader>/` |
| Go to definition | `gd` |
| Find references | `gr` |
| Hover documentation | `K` |
| Quick Fix / code action | `<leader>ca` |
| Rename symbol | `<leader>cr` |
| Format document | `<leader>cf` |
| Previous/next diagnostic | `[d` / `]d` |
| Problems panel | `<leader>xx` |
| Source control UI | `<leader>gg` |
| Integrated terminal | `<C-/>` |
| Toggle breakpoint | `<leader>db` |
| Start/continue debugging | `<leader>dc` |
| Step over / step into | `<leader>dO` / `<leader>di` |

Leader mappings begin with `Space`. If a mapping changes in a future LazyVim release, press `Space` and follow WhichKey instead of memorizing plugin commands.

## A First Editing Session

1. Run `nvim .` in a Git project.
2. Open the explorer with `<leader>e`, or find a file with `<leader><space>`.
3. Press `/` to search inside the file; use `n` and `N` for next and previous matches.
4. Use `<leader>/` to search the entire project with ripgrep.
5. Place the cursor on a symbol and try `gd`, `gr`, and `K`.
6. Rename it with `<leader>cr`; inspect edits before saving.
7. Apply a code action with `<leader>ca` and format with `<leader>cf`.
8. Review diagnostics with `[d`, `]d`, and `<leader>xx`.
9. Open LazyGit with `<leader>gg` to inspect and stage the change.
10. Open a terminal with `<C-/>` for project commands.

## Language Tooling

LazyVim configures Neovim's LSP client and Mason manages external development tools. Open `:Mason` to inspect installation status. Use `:LspInfo` in a source buffer to confirm the expected server attached.

The configuration enables format-on-save. Prettier handles supported web and data formats, language extras provide their normal formatters, and Bash uses `shfmt -i 4 -ci` to match this repository. Run `<leader>cf` for an explicit format.

Java tooling requires the workstation OpenJDK 21 runtime. Projects may still target older Java bytecode through Maven, Gradle, or project-local toolchains.

## Debugging

Open a supported source file, set a breakpoint with `<leader>db`, and start or continue with `<leader>dc`. Choose the launch configuration when prompted. The DAP UI opens around the current session. Use `<leader>dO` to step over and `<leader>di` to step into. Press `Space`, then `d`, to discover the remaining debug actions.

Adapters are installed by Mason. If a debugger is unavailable, inspect `:Mason` before changing Lua configuration.

## Git, Terminal, and Sessions

- `<leader>gg` opens LazyGit in a floating terminal.
- `<C-/>` toggles the integrated terminal.
- LazyVim automatically records project sessions. Use the `Space q` WhichKey group to restore or manage them.
- Gitsigns marks added, changed, and deleted lines in the sign column. Press `Space g` to discover hunk actions.

## Plugin and Lockfile Maintenance

`config/nvim/lazy-lock.json` pins plugin commits. Normal startup may check for updates but does not apply them.

- `:Lazy sync` installs the locked state and removes untracked plugins.
- `:Lazy update` intentionally updates plugins and rewrites the lockfile.
- Commit lockfile changes together with configuration changes.
- `:Lazy restore` returns installed plugins to the tracked lockfile.

Mason packages are separate from the plugin lockfile. Reopen `:Mason` or restart Neovim to retry a failed network installation.

## Local Customization Boundaries

Tracked behavior belongs in `config/nvim/lua/plugins/` or the extension files under `config/nvim/lua/config/`. Keep one source for each behavior and prefer LazyVim extras over parallel hand-written LSP or DAP setup. `deprecated/nvim/` is historical reference and is never loaded.

Machine-specific shell environment overrides belong in `~/.extra`. Do not edit the deployed `~/.config/nvim` symlink as though it were untracked machine state; edits there modify this repository.

## Troubleshooting

Run these commands inside Neovim:

- `:checkhealth lazyvim`: LazyVim, executable, and tree-sitter provider health.
- `:checkhealth`: Neovim-wide provider diagnostics, including clipboard support.
- `:LspInfo`: attached language servers and root detection.
- `:Mason`: language tool installation state and logs.
- `:Lazy`: plugin state, logs, sync, restore, and updates.

From the shell, run `./verify.sh` to check Neovim 0.11.2+, fd, LazyGit, tree-sitter CLI, and Java 21 along with the rest of the workstation.

If startup fails after a plugin change, run:

```bash
nvim --headless "+Lazy! sync" +qa
```

If plugin installation was interrupted, reopen Neovim and use `:Lazy sync`. If Mason installation was interrupted, reopen `:Mason` and retry the failed package. Preserve the real error; do not replace the tracked configuration with an empty fallback.
