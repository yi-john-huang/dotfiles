# Project Structure

## Directory Layout

```text
dotfiles/
├── bootstrap.sh              # Main entry point for machine setup
├── verify.sh                 # Post-install verification script
├── fix-binaries.sh           # Reinstall architecture-sensitive binaries
├── setup-utm-ubuntu.sh       # Ubuntu 24.04 UTM test setup helper
├── README.md                 # User-facing setup and architecture documentation
├── MIGRATION.md              # Migration notes from older dotfiles
├── LICENSE-MIT.txt           # Project license
├── lib/                      # Shared shell libraries
│   ├── detect.sh             # OS and architecture detection
│   ├── utils.sh              # Logging and command helpers
│   └── podman-utils.sh       # Podman machine helper functions
├── install/                  # Installer modules
│   ├── macos.sh              # macOS-specific packages and apps
│   ├── ubuntu.sh             # Ubuntu-specific packages and Docker setup
│   ├── common.sh             # Cross-platform CLI tools
│   └── dev-tools.sh          # Language runtimes and developer tooling
├── config/                   # Dotfile payloads deployed by bootstrap
│   ├── shell/                # .bashrc and .zshrc templates
│   ├── git/                  # Git config include and global ignore
│   ├── tmux/                 # tmux configuration
│   ├── zellij/               # Zellij configuration
│   ├── alacritty/            # Alacritty configuration
│   └── ghostty/              # Reserved terminal configuration directory
├── scripts/                  # Operational helper scripts
│   ├── x86-start.sh          # Start Podman x86_64 machine
│   ├── x86-build.sh          # Build amd64 images with Podman
│   ├── x86-compose.sh        # Run compose with amd64 platform
│   └── x86-stop.sh           # Stop Podman x86_64 machine
├── tests/                    # Bats tests for installers and helpers
├── docs/                     # Supplemental user documentation
├── deprecated/               # Historical dotfiles kept for reference
└── .spec/steering/           # Tracked SDD steering documents only
```

## Repository Boundaries
- `.spec/steering/` is the only tracked SDD/AI steering content.
- Generated SDD specs, Claude skills/rules/agents/hooks, Codex `AGENTS.md`, `.agent/`, and `.claude-plugin/` are ignored.
- `deprecated/` is reference material. Do not wire new bootstrap behavior to deprecated files.
- Machine-local overrides belong outside Git or in ignored local files.

## Naming Conventions

### Files
| Type | Convention | Example |
|------|------------|---------|
| Entry scripts | Lowercase kebab-case or clear verb phrase with `.sh` | `fix-binaries.sh`, `setup-utm-ubuntu.sh` |
| Installer modules | Lowercase domain name with `.sh` | `common.sh`, `dev-tools.sh` |
| Library modules | Lowercase noun with `.sh` | `detect.sh`, `utils.sh` |
| Operational scripts | Prefix by workflow, then action | `x86-start.sh`, `x86-compose.sh` |
| Tests | Module or behavior name with `.bats` | `detect.bats`, `dev-tools.bats` |
| Config payloads | Match target application filename/path | `.tmux.conf`, `config.kdl`, `alacritty.toml` |
| Local overrides | Use explicit local filename and keep ignored | `.tmux.local`, `local.toml`, `~/.extra` |

### Shell Code
| Element | Convention | Example |
|---------|------------|---------|
| Functions | `snake_case` with verb-first names | `install_common_tools`, `check_command` |
| Global constants | `UPPER_SNAKE_CASE` | `DOTFILES_DIR`, `OS_ARCH` |
| Environment variables | `UPPER_SNAKE_CASE` | `NVM_DIR`, `GOPATH` |
| Local variables | `lower_snake_case` | `script_dir`, `failed` |
| Booleans | String values `true` / `false` for exported flags | `IS_MACOS="true"` |
| Logs | Use `log_info`, `log_warn`, and `log_error` | `log_info "Installing common tools..."` |

## Module Organization

### Script Skeleton
Use this order for new shell scripts:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/lib/detect.sh"
source "${PROJECT_ROOT}/lib/utils.sh"

# constants
# functions
# main entry point
```

Installer modules that intentionally continue after individual install failures may use `set -uo pipefail` and explicit failure counters, matching `install/common.sh` and `install/dev-tools.sh`.

### Dependency Direction
- Entry scripts may source `lib/*` and `install/*`.
- Installer modules may source `lib/detect.sh` and `lib/utils.sh`.
- Shared helper logic belongs in `lib/`, not duplicated across scripts.
- Config payloads under `config/` should not source installer modules.
- Tests may source the module under test and assert functions or observable command behavior.

### Platform Separation
- macOS-only behavior belongs in `install/macos.sh`.
- Ubuntu-only behavior belongs in `install/ubuntu.sh`.
- Cross-platform CLI tools belong in `install/common.sh`.
- Language runtimes and developer SDKs belong in `install/dev-tools.sh`.
- Platform detection belongs in `lib/detect.sh`; do not reimplement `uname` parsing in installers.

## Deployment Patterns
- Back up existing non-symlink user files before replacing them.
- Copy shell rc files when local edits are expected.
- Symlink stable application configs from `config/` when repository updates should flow through automatically.
- Use Git `include.path` for repository-managed Git config instead of overwriting a user's entire `~/.gitconfig`.
- Prefer XDG config directories for terminal applications: `${XDG_CONFIG_HOME:-$HOME/.config}/alacritty` and `${XDG_CONFIG_HOME:-$HOME/.config}/zellij`.
- Keep user secrets, Git credentials, and machine-specific aliases in `~/.extra` or local Git config, not in tracked files.

## Error Handling Patterns
- Use strict mode in entry scripts unless the script intentionally aggregates installer failures.
- Use `check_command` before installing tools or assuming command availability.
- Log actionable failures with `log_error` and return non-zero for required setup failures.
- Use `log_warn` for optional or recoverable install failures.
- Keep idempotency checks close to the install step they protect.

## Testing Structure
- `tests/*.bats` contains Bats tests for module existence, platform detection, utility helpers, and architecture-sensitive binaries.
- Add or update Bats tests when adding installer functions, detection branches, helper functions, or deployment behavior that can be exercised without mutating the host.
- Use `./verify.sh` for end-to-end installed-tool validation after bootstrap changes.
- Use UTM or the x86 Podman helpers for architecture and platform coverage that cannot be represented by unit-style Bats tests.

## Documentation Rules
- Keep `README.md` user-facing: setup, usage, architecture summary, troubleshooting.
- Keep `.spec/steering/` maintainer-facing: product context, technology decisions, and repository conventions for AI-assisted work.
- Update steering when changing supported platforms, installed tool categories, bootstrap phases, or tracked/ignored AI-agent files.
