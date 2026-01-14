# dotfiles

AI駆動開発環境に最適化された個人用設定ファイル

## 特徴

- **Claude Code統合** - MCPサーバー13個設定済み
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
| `.zshrc`, `.aliases` | シェル設定 |
| `Brewfile` / `Brewfile.full` | 必須/全アプリ |
| `.claude/` | Claude Code（MCPサーバー等） |
| `nvim/` | Neovim設定 |
| `tmux/` | tmux設定 |
| `ghostty/` | Ghosttyターミナル |
| `git/`, `gh/` | Git/GitHub CLI設定 |
| `bat/` | bat設定 |
| `raycast/` | Raycastスクリプト |
| `antigravity/` | Antigravity設定 |
| `scripts/` | ユーティリティスクリプト |

## ドキュメント

| ファイル | 内容 |
|---------|------|
| [SETUP.md](docs/SETUP.md) | 詳細セットアップ手順 |
| [APPS.md](docs/APPS.md) | アプリケーション一覧 |
| [mcp-servers-guide.md](docs/mcp-servers-guide.md) | MCPサーバー設定ガイド |
| [BROWSER_EXTENSIONS.md](docs/BROWSER_EXTENSIONS.md) | ブラウザ拡張機能 |

## 参考

- [GitHub does dotfiles](https://dotfiles.github.io/)
