# dotfiles

macOS用の個人設定ファイル

[🇬🇧 English](../README.md)

## 特徴

- **Claude Code統合** - MCPサーバー設定済み
- **モダンCLI** - bat, eza, fzf, ripgrep等
- **自動セットアップ** - bootstrap.shで一発構築

## クイックスタート

```bash
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash bootstrap.sh
```

## 構成

| ディレクトリ | 内容 |
|-------------|------|
| `stow/zsh/` | シェル設定（.zshrc, .aliases） |
| `stow/claude/` | Claude Code（agents, commands, hooks） |
| `Brewfile` | Homebrewパッケージ |
| `stow/nvim/` | Neovim設定 |
| `stow/tmux/` | tmux設定 |
| `stow/ghostty/` | Ghosttyターミナル |
| `stow/git/`, `gh/` | Git/GitHub CLI設定 |
| `ssh/` | SSH設定 |
| `stow/bat/`, `stow/atuin/` | bat/atuin設定 |
| `raycast/` | Raycastスクリプト |
| `antigravity/` | Antigravity設定 |
| `scripts/` | ユーティリティスクリプト |

## テーマ

全ツールで **TokyoNight** テーマを統一使用:

- Neovim, tmux, Ghostty, bat

## ドキュメント

| ファイル | 内容 |
|---------|------|
| [SETUP.md](setup/SETUP.md) | 詳細セットアップ手順 |
| [APPS.md](setup/APPS.md) | アプリケーション一覧 |
| [mcp-servers-guide.md](integrations/mcp-servers-guide.md) | MCPサーバー設定ガイド |
| [atlassian-guide.md](integrations/atlassian-guide.md) | Jira/Confluence連携 |

## 参考

- [GitHub does dotfiles](https://dotfiles.github.io/)
