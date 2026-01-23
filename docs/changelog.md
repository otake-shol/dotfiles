# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Cross-platform support (Linux, WSL)
- GNU Stow-based symlink management
- MkDocs documentation site
- Comprehensive test suite (bats-core)
- Demo GIF recording scripts
- devcontainer support
- GitHub Actions CI/CD improvements
- English documentation

### Changed

- Modularized aliases into separate files
- Improved zsh startup performance with plugin caching
- Enhanced bootstrap script with more options

### Fixed

- Various symlink path corrections
- Documentation link fixes

## [1.0.0] - 2024-01-01

### Added

- Initial release
- Zsh configuration with Oh My Zsh
- Powerlevel10k theme
- Modern CLI tools (bat, eza, fzf, ripgrep, etc.)
- Neovim configuration with LSP
- tmux configuration
- Ghostty terminal configuration
- Git configuration with delta
- Claude Code integration with MCP servers
- Custom aliases and functions
- Homebrew package management
- TokyoNight theme across all tools

---

## Version Guidelines

- **Major** (1.0.0): Breaking changes, major feature additions
- **Minor** (0.1.0): New features, backward compatible
- **Patch** (0.0.1): Bug fixes, documentation updates

## How to Update

```bash
cd ~/dotfiles
git pull origin master
bash bootstrap.sh
```

Or use the update alias:

```bash
dotupdate
```
