# dotfiles

<p align="center">
  <strong>A modern, cross-platform dotfiles repository with AI-driven development integration</strong>
</p>

<p align="center">
  <a href="https://github.com/otake-shol/dotfiles/actions/workflows/lint.yml">
    <img src="https://github.com/otake-shol/dotfiles/actions/workflows/lint.yml/badge.svg" alt="Lint">
  </a>
  <a href="https://github.com/otake-shol/dotfiles/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/otake-shol/dotfiles" alt="License">
  </a>
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20WSL-blue" alt="Platform">
</p>

---

## Features

<div class="grid cards" markdown>

- :material-apple: :material-linux: :material-microsoft-windows:{ .lg .middle } **Cross-Platform**

    ---

    Works seamlessly on macOS, Linux, and WSL

- :material-robot:{ .lg .middle } **AI-Driven Development**

    ---

    Pre-configured Claude Code with 13 MCP servers

- :material-console:{ .lg .middle } **Modern CLI Tools**

    ---

    bat, eza, fzf, ripgrep, zoxide, and more

- :material-rocket-launch:{ .lg .middle } **One-Command Setup**

    ---

    Fully automated bootstrap script

- :material-palette:{ .lg .middle } **Theme Unified**

    ---

    TokyoNight theme across all tools

- :material-file-document:{ .lg .middle } **Well Documented**

    ---

    Comprehensive guides for everything

</div>

## Quick Start

=== "macOS"

    ```bash
    git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
    cd ~/dotfiles && bash bootstrap.sh
    ```

=== "Linux"

    ```bash
    git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
    cd ~/dotfiles && bash bootstrap.sh
    ```

=== "WSL"

    ```bash
    git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
    cd ~/dotfiles && bash bootstrap.sh
    ```

!!! tip "Dry run first"
    Preview changes without applying: `bash bootstrap.sh --dry-run`

## What's Included

### Modern CLI Tools

| Legacy | Modern | Description |
|--------|--------|-------------|
| `cat` | `bat` | Syntax highlighting, line numbers |
| `ls` | `eza` | Icons, Git integration, tree view |
| `grep` | `rg` | ripgrep - blazingly fast search |
| `find` | `fd` | User-friendly, fast file finder |
| `du` | `dust` | Intuitive disk usage visualization |
| `cd` | `zoxide` | Smart directory jumping |
| `diff` | `delta` | Beautiful side-by-side diffs |

### AI-Driven Development

| Component | Description |
|-----------|-------------|
| **Claude Code** | CLI AI assistant with custom agents |
| **MCP Servers** | 13 pre-configured servers |
| **Custom Commands** | `/commit-push`, `/review`, `/test`, `/spec` |
| **Hooks** | Auto Brewfile update, completion notifications |

## Documentation

<div class="grid cards" markdown>

- [:material-book-open-page-variant: **Getting Started**](getting-started/quick-start.md)

    ---

    Step-by-step installation and configuration guide

- [:material-robot: **AI Workflow**](ai-workflow/AI-DRIVEN-DEV-GUIDE.md)

    ---

    Complete AI-driven development setup

- [:material-puzzle: **Integrations**](integrations/mcp-servers-guide.md)

    ---

    MCP servers, Jira, Confluence, and more

- [:material-format-list-bulleted: **Reference**](reference/aliases.md)

    ---

    All aliases, functions, and scripts

</div>

## Community

- [:fontawesome-brands-github: GitHub](https://github.com/otake-shol/dotfiles)
- [:material-bug: Issues](https://github.com/otake-shol/dotfiles/issues)
- [:material-source-pull: Pull Requests](https://github.com/otake-shol/dotfiles/pulls)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/otake-shol/dotfiles/blob/master/LICENSE) file for details.
