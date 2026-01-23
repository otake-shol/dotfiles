# Contributing to dotfiles

Thank you for your interest in contributing! This document provides guidelines for contributing to this dotfiles repository.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Style Guidelines](#style-guidelines)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Bugs

1. Check if the issue already exists in [GitHub Issues](https://github.com/otake-shol/dotfiles/issues)
2. If not, create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, shell version, etc.)

### Suggesting Features

1. Open a [GitHub Issue](https://github.com/otake-shol/dotfiles/issues/new) with:
   - Clear description of the feature
   - Use case and benefits
   - Possible implementation approach (optional)

### Submitting Changes

1. Fork the repository
2. Create a feature branch from `master`
3. Make your changes
4. Run tests and linting
5. Submit a Pull Request

## Development Setup

### Prerequisites

- macOS, Linux, or WSL
- Git
- Bash 4.0+
- ShellCheck (for linting)

### Local Development

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles-dev
cd ~/dotfiles-dev

# Install development dependencies
brew install shellcheck bats-core

# Run linting
make lint

# Run tests
make test

# Dry run bootstrap
bash bootstrap.sh --dry-run
```

## Style Guidelines

### Shell Scripts

- Use `#!/bin/bash` for bash scripts, `#!/bin/zsh` for zsh-specific
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use `set -e` for error handling
- Quote all variables: `"$variable"` not `$variable`
- Use `[[ ]]` for conditionals (bash/zsh)
- Add comments for non-obvious logic

```bash
# Good
if [[ -f "$config_file" ]]; then
    source "$config_file"
fi

# Bad
if [ -f $config_file ]; then
    source $config_file
fi
```

### Naming Conventions

- Files: `lowercase-with-dashes.sh`
- Functions: `snake_case`
- Variables: `UPPERCASE` for constants, `lowercase` for locals
- Aliases: short, memorable, lowercase

### Documentation

- Use Markdown for documentation
- Include code examples where helpful
- Keep README concise, link to detailed docs
- Update documentation when changing features

## Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

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

```
feat: add Linux/WSL support to bootstrap script

fix: resolve symlink creation on existing files

docs: update README with new CLI tools

refactor: modularize alias files by category

chore: update Brewfile with new packages
```

## Pull Request Process

### Before Submitting

1. **Test your changes**

   ```bash
   # Run dry-run to verify
   bash bootstrap.sh --dry-run

   # Run linting
   make lint

   # Run tests if available
   make test
   ```

2. **Update documentation** if needed

3. **Ensure CI passes** locally

### PR Guidelines

1. **Title**: Use conventional commit format
   - `feat: add zsh plugin lazy loading`
   - `fix: resolve WSL clipboard integration`

2. **Description**: Include
   - What changes were made
   - Why they were made
   - How to test
   - Screenshots if UI-related

3. **Size**: Keep PRs focused and small
   - One feature/fix per PR
   - Split large changes into multiple PRs

### Review Process

1. Maintainer will review within 1-2 weeks
2. Address feedback in new commits
3. Once approved, maintainer will merge
4. Your contribution will be credited in the release notes

## Testing

### Manual Testing Checklist

- [ ] Bootstrap runs without errors (`--dry-run`)
- [ ] Symlinks are created correctly
- [ ] Shell starts without errors
- [ ] Aliases work as expected
- [ ] No ShellCheck warnings

### Automated Tests

```bash
# Run all tests
make test

# Run specific test file
bats tests/bootstrap.bats
```

## Questions?

Feel free to:

- Open a [Discussion](https://github.com/otake-shol/dotfiles/discussions)
- Ask in the PR/Issue comments

Thank you for contributing!
