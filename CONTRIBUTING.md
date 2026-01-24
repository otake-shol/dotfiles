# Contributing to dotfiles

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Commit Convention](#commit-convention)
- [Pull Request Process](#pull-request-process)
- [Style Guide](#style-guide)

## Code of Conduct

Be respectful and constructive. We're all here to learn and improve.

## Getting Started

### Prerequisites

- macOS 12.0+ / Linux / WSL2
- Git
- Homebrew (macOS) or apt/dnf/pacman (Linux)

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run bootstrap in dry-run mode to verify
bash bootstrap.sh --dry-run

# Install development dependencies
brew install shellcheck bats-core
```

## Development Workflow

### Branch Naming

Use descriptive branch names:

```
feature/add-new-alias
fix/zsh-startup-speed
docs/update-readme
refactor/simplify-bootstrap
```

### Making Changes

1. Create a feature branch from `master`
2. Make your changes
3. Run tests locally
4. Commit with conventional commit message
5. Push and create a PR

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/).

### Format

```
<type>: <subject>

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code restructuring |
| `perf` | Performance improvement |
| `test` | Adding/updating tests |
| `chore` | Maintenance tasks |
| `ci` | CI/CD changes |

### Examples

```bash
# Good
feat: add fzf integration for git branch selection
fix: resolve zsh startup delay caused by nvm
docs: update installation instructions for WSL
refactor: split .zshrc into modular files
perf: lazy-load asdf to reduce startup time

# Bad
update stuff
fix bug
WIP
```

### Commit Template

A commit template is available at `stow/git/commit-template.txt`. To use it:

```bash
git config --local commit.template stow/git/commit-template.txt
```

## Pull Request Process

### Before Submitting

1. **Run linting**
   ```bash
   make lint
   ```

2. **Verify setup**
   ```bash
   make health
   ```

### PR Guidelines

- Keep PRs focused and small
- Update documentation if needed
- Ensure CI passes

### PR Template

```markdown
## Summary
Brief description of changes

## Changes
- Change 1
- Change 2

## Testing
How you tested the changes

## Checklist
- [ ] Ran `make lint`
- [ ] Ran `make health`
- [ ] Updated documentation (if applicable)
```

## Style Guide

### Shell Scripts

- Use `#!/bin/bash` with `set -euo pipefail`
- Quote variables: `"$var"` not `$var`
- Use `[[` instead of `[` for tests
- Declare local variables with `local`
- Follow [ShellCheck](https://www.shellcheck.net/) recommendations

### Zsh Configuration

- Group related settings with comment headers
- Use descriptive alias names
- Document complex functions
- Keep startup time in mind (lazy-load when possible)

### File Organization

- One concern per file
- Use GNU Stow package structure
- Keep sensitive data in `.local` files (git-ignored)

## Questions?

Open an issue with the `question` label or start a discussion.

---

Thank you for contributing!
