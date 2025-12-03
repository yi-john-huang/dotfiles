# Implementation Tasks

## Project: simplify
**Feature**: Refactor dotfiles into simplified bootstrap system  
**Generated**: 2025-12-02T15:48:02.967Z

---

## Phase 1: Project Structure Setup

### Task 1.1: Create Directory Structure
**Status**: completed  
**Priority**: high  
**Dependencies**: none

Create the new modular directory structure:
```
lib/
install/
config/shell/
config/nvim/
config/git/
deprecated/
```

**Acceptance Criteria**:
- All directories created
- README.md in deprecated/ explaining its purpose

---

### Task 1.2: Move Obsolete Files to Deprecated
**Status**: completed  
**Priority**: high  
**Dependencies**: 1.1

Analyze current dotfiles and move unused/obsolete files to deprecated/:
- Old configuration files not needed in new structure
- Unused scripts
- Legacy tool configurations

**Acceptance Criteria**:
- All obsolete files moved to deprecated/
- deprecated/README.md lists what was moved and why

---

## Phase 2: Core Infrastructure

### Task 2.1: Write Tests for Platform Detection
**Status**: completed  
**Priority**: high  
**Dependencies**: 1.1

**TDD Red Phase**: Write failing tests for lib/detect.sh:
- Test macOS detection
- Test Ubuntu detection
- Test ARM64 detection
- Test x86_64 detection
- Test unknown platform handling

**Acceptance Criteria**:
- Test file: tests/detect.bats (using bats-core)
- All tests fail initially (Red phase)
- Tests cover all detection scenarios

---

### Task 2.2: Create Platform Detection (lib/detect.sh)
**Status**: completed  
**Priority**: high  
**Dependencies**: 2.1

**TDD Green Phase**: Implement OS and architecture detection:
```bash
# Exports: OS_TYPE, OS_ARCH, IS_MACOS, IS_UBUNTU
```

**Acceptance Criteria**:
- All tests from 2.1 pass (Green phase)
- Detects macOS vs Ubuntu
- Detects ARM64 vs x86_64
- Exports variables for other scripts
- Handles unknown platforms gracefully

---

### Task 2.3: Write Tests for Utility Functions
**Status**: completed  
**Priority**: high  
**Dependencies**: 1.1

**TDD Red Phase**: Write failing tests for lib/utils.sh:
- Test log_info/warn/error output
- Test check_command with existing/missing commands
- Test error handling and cleanup

**Acceptance Criteria**:
- Test file: tests/utils.bats
- All tests fail initially
- Tests cover all utility functions

---

### Task 2.4: Create Utility Functions (lib/utils.sh)
**Status**: completed  
**Priority**: high  
**Dependencies**: 2.3

**TDD Green Phase**: Implement logging and helper functions:
```bash
log_info(), log_warn(), log_error()
check_command()
```

**Acceptance Criteria**:
- All tests from 2.3 pass
- Color-coded log output
- check_command validates tool installation
- Error handling with cleanup trap

---

### Task 2.5: Security Review - Core Infrastructure
**Status**: completed  
**Priority**: high  
**Dependencies**: 2.2, 2.4

**Security Check**: Validate against OWASP guidelines:
- A03: Injection - Validate all inputs, no eval of user input
- A05: Security Misconfiguration - No debug output in production
- A09: Logging - Log errors without exposing sensitive paths

**Acceptance Criteria**:
- No use of eval or exec with untrusted input
- Input validation for all parameters
- Safe error messages (no sensitive data leakage)

---

## Phase 3: Installation Modules

### Task 3.1: Write Tests for macOS Installer
**Status**: completed  
**Priority**: high  
**Dependencies**: 2.2, 2.4

**TDD Red Phase**: Write failing tests for install/macos.sh:
- Test Homebrew installation check
- Test iTerm2 installation
- Test Colima installation
- Test idempotency (run twice)

**Acceptance Criteria**:
- Test file: tests/macos.bats
- All tests fail initially
- Mock brew commands for testing

---

### Task 3.2: Create macOS Installer (install/macos.sh)
**Status**: pending  
**Priority**: high  
**Dependencies**: 3.1

**TDD Green Phase**: Implement macOS-specific installations:
- Homebrew (non-root, /opt/homebrew)
- iTerm2 via brew cask
- Colima

**Acceptance Criteria**:
- All tests from 3.1 pass
- Idempotent (checks before installing)
- Handles Apple Silicon specifics
- Logs progress

---

### Task 3.3: Write Tests for Ubuntu Installer
**Status**: pending  
**Priority**: high  
**Dependencies**: 2.2, 2.4

**TDD Red Phase**: Write failing tests for install/ubuntu.sh:
- Test apt package installation
- Test system dependencies
- Test idempotency

**Acceptance Criteria**:
- Test file: tests/ubuntu.bats
- All tests fail initially
- Mock apt commands for testing

---

### Task 3.4: Create Ubuntu Installer (install/ubuntu.sh)
**Status**: pending  
**Priority**: high  
**Dependencies**: 3.3

**TDD Green Phase**: Implement Ubuntu-specific installations:
- apt packages
- System dependencies

**Acceptance Criteria**:
- All tests from 3.3 pass
- Idempotent
- Handles x86_64 architecture
- Updates apt cache before installing

---

### Task 3.5: Write Tests for Common Tools Installer
**Status**: pending  
**Priority**: high  
**Dependencies**: 3.2, 3.4

**TDD Red Phase**: Write failing tests for install/common.sh:
- Test each tool installation
- Test cross-platform compatibility
- Test idempotency

**Acceptance Criteria**:
- Test file: tests/common.bats
- All tests fail initially
- Tests work on both macOS and Ubuntu

---

### Task 3.6: Create Common Tools Installer (install/common.sh)
**Status**: pending  
**Priority**: high  
**Dependencies**: 3.5

**TDD Green Phase**: Install cross-platform CLI tools:
- jq, yq
- ripgrep, bat
- zellij
- kubectl, kubectx, k9s
- Terraform

**Acceptance Criteria**:
- All tests from 3.5 pass
- Works on both macOS and Ubuntu
- Idempotent
- Verifies each installation

---

### Task 3.7: Write Tests for Dev Tools Installer
**Status**: pending  
**Priority**: high  
**Dependencies**: 3.6

**TDD Red Phase**: Write failing tests for install/dev-tools.sh:
- Test nvm installation
- Test uv installation
- Test Go installation
- Test Java/Spring Boot tools
- Test PATH configuration

**Acceptance Criteria**:
- Test file: tests/dev-tools.bats
- All tests fail initially
- Tests verify PATH setup

---

### Task 3.8: Create Dev Tools Installer (install/dev-tools.sh)
**Status**: pending  
**Priority**: high  
**Dependencies**: 3.7

**TDD Green Phase**: Install language runtimes and tools:
- nvm + Node.js/TypeScript
- uv for Python
- Go toolchain
- Java/Spring Boot tools

**Acceptance Criteria**:
- All tests from 3.7 pass
- Configures PATH for each tool
- Sets up version managers
- Idempotent

---

### Task 3.9: Security Review - Installation Modules
**Status**: pending  
**Priority**: high  
**Dependencies**: 3.2, 3.4, 3.6, 3.8

**Security Check**: Validate against OWASP guidelines:
- A03: Injection - No curl | bash patterns, verify downloads
- A06: Vulnerable Components - Install from official sources only
- A08: Software Integrity - Verify checksums where possible
- A10: SSRF - Validate download URLs

**Acceptance Criteria**:
- All downloads use HTTPS
- No piping curl to bash without verification
- Official package sources only
- Document any manual download steps

---

## Phase 4: Configuration Deployment

### Task 4.1: Create Shell Configurations (config/shell/)
**Status**: pending  
**Priority**: high  
**Dependencies**: 3.4

Create .bashrc and .zshrc:
- PATH configuration
- Aliases
- Functions
- Source ~/.extra if exists

**Acceptance Criteria**:
- Works on both bash and zsh
- Includes all tool paths
- Documented aliases

---

### Task 4.2: Create Neovim Configuration (config/nvim/)
**Status**: pending  
**Priority**: medium  
**Dependencies**: 3.4

Setup Neovim with lazy.nvim:
- lazy.nvim bootstrap
- Plugin configurations
- LSP for Java, TypeScript, Python, Go

**Acceptance Criteria**:
- Plugins auto-install on first launch
- LSP working for all languages
- Minimal, clean config

---

### Task 4.3: Create Git Configuration (config/git/)
**Status**: pending  
**Priority**: medium  
**Dependencies**: 1.1

Create .gitconfig and .gitignore_global:
- Basic git settings
- Global ignore patterns

**Acceptance Criteria**:
- Respects ~/.extra for user-specific settings
- Includes common ignore patterns

---

## Phase 5: Bootstrap Orchestration

### Task 5.1: Create Main Bootstrap Script (bootstrap.sh)
**Status**: pending  
**Priority**: high  
**Dependencies**: 2.1, 2.2, 3.1, 3.2, 3.3, 3.4, 4.1

Main entry point that orchestrates:
1. Platform detection
2. Installation sequence
3. Configuration deployment
4. Symlink creation

**Acceptance Criteria**:
- Single command execution
- Progress feedback
- Handles --force and --skip-verify flags
- Error handling with cleanup

---

### Task 5.2: Create Symlink Manager
**Status**: pending  
**Priority**: high  
**Dependencies**: 5.1

Create symlinks for dotfiles:
- ~/.bashrc → config/shell/.bashrc
- ~/.zshrc → config/shell/.zshrc
- ~/.config/nvim → config/nvim/
- ~/.gitconfig → config/git/.gitconfig

**Acceptance Criteria**:
- Backs up existing files
- Creates symlinks safely
- Idempotent

---

## Phase 6: Verification

### Task 6.1: Create Verification Script (verify.sh)
**Status**: pending  
**Priority**: medium  
**Dependencies**: 5.1

Validate all installations:
- Check each tool is installed
- Verify versions
- Report missing tools

**Acceptance Criteria**:
- Lists all tools with versions
- Clear pass/fail report
- Exit code reflects success/failure

---

### Task 6.2: Test on macOS
**Status**: pending  
**Priority**: high  
**Dependencies**: 6.1

Test complete bootstrap on fresh macOS (Apple Silicon):
- Run bootstrap.sh
- Verify all tools work
- Test idempotency (run twice)

**Acceptance Criteria**:
- Completes in under 30 minutes
- All tools functional
- No errors on second run

---

### Task 6.3: Test on Ubuntu
**Status**: pending  
**Priority**: high  
**Dependencies**: 6.1

Test complete bootstrap on fresh Ubuntu 24 LTS (x86_64):
- Run bootstrap.sh
- Verify all tools work
- Test idempotency

**Acceptance Criteria**:
- Completes in under 30 minutes
- All tools functional
- No errors on second run

---

## Phase 7: Documentation

### Task 7.1: Update README.md
**Status**: pending  
**Priority**: medium  
**Dependencies**: 6.2, 6.3

Update main README with:
- New simplified structure
- Installation instructions
- Supported platforms
- Troubleshooting

**Acceptance Criteria**:
- Clear installation steps
- Architecture diagram
- Platform requirements listed

---

### Task 7.2: Create MIGRATION.md
**Status**: pending  
**Priority**: low  
**Dependencies**: 7.1

Document migration from old dotfiles:
- What changed
- How to migrate custom configs
- Using ~/.extra for overrides

**Acceptance Criteria**:
- Step-by-step migration guide
- Examples of common customizations

---

## Summary

**Total Tasks**: 28 (16 implementation + 10 TDD + 2 security reviews)  
**Estimated Completion**: 12-16 hours  
**Critical Path**: 1.1 → 2.1 → 2.2 → 2.3 → 2.4 → 2.5 → 3.1 → 3.2 → 3.5 → 3.6 → 3.7 → 3.8 → 3.9 → 4.1 → 5.1 → 6.1 → 6.2

**Key Milestones**:
1. Phase 2 complete: Core infrastructure ready with tests
2. Phase 3 complete: All installers working with security validation
3. Phase 5 complete: Bootstrap functional
4. Phase 6 complete: Tested on both platforms

**TDD Compliance**:
- All core modules have test-first development
- Red-Green-Refactor cycle enforced
- Using bats-core for bash testing

**Security Compliance**:
- OWASP Top 10 checks integrated
- Security reviews after each major phase
- Input validation and safe download practices
