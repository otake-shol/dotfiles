# dotfiles

macOS用の個人設定ファイル

[🇬🇧 English](../README.md)

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
| `git/`, `gh/` | Git/GitHub CLI設定、コミット/PRテンプレート |
| `ssh/` | SSH設定 |
| `bat/`, `atuin/` | bat/atuin設定 |
| `raycast/` | Raycastスクリプト |
| `antigravity/` | Antigravity設定 |
| `browser-extensions/` | ブラウザ拡張機能リスト |
| `scripts/` | ユーティリティスクリプト |
| `espanso/` | テキスト展開（AIプロンプトスニペット） |

## テーマ

全ツールで **TokyoNight** テーマを統一使用:

- Neovim, tmux, Ghostty, bat

## バックアップ

### Raycast設定

1. Raycast → Settings → Advanced → Export
2. `~/dotfiles/raycast/` に保存

### 1Password SSH Agent

SSHキーを1Passwordで管理する場合は `ssh/config` のコメントを解除

## ドキュメント

### AI駆動開発（推奨）

| ファイル | 内容 |
|---------|------|
| [AI-DRIVEN-DEV-GUIDE.md](docs/ai-workflow/AI-DRIVEN-DEV-GUIDE.md) | AI駆動開発環境 完全ガイド |
| [SPEC-DRIVEN-DEV.md](docs/ai-workflow/SPEC-DRIVEN-DEV.md) | 仕様駆動開発ガイド |
| [AI-PROMPTS.md](docs/ai-workflow/AI-PROMPTS.md) | AIプロンプトテンプレート集 |

### ツール連携

| ファイル | 内容 |
|---------|------|
| [mcp-servers-guide.md](docs/integrations/mcp-servers-guide.md) | MCPサーバー設定ガイド |
| [claude-code-jira-guide.md](docs/integrations/claude-code-jira-guide.md) | Claude Code × Jira連携 |
| [confluence-requirements-doc-automation.md](docs/integrations/confluence-requirements-doc-automation.md) | Confluence要件書自動化 |
| [slack-jira-workflow-guide.md](docs/integrations/slack-jira-workflow-guide.md) | Slack-Jiraワークフロー |

### セットアップ・ツール

| ファイル | 内容 |
|---------|------|
| [SETUP.md](docs/setup/SETUP.md) | 詳細セットアップ手順 |
| [APPS.md](docs/setup/APPS.md) | アプリケーション一覧 |
| [DOTFILES_MANAGER.md](docs/setup/DOTFILES_MANAGER.md) | dotfiles管理ツール比較 |
| [antigravity-extensions.md](docs/tools/antigravity-extensions.md) | Antigravity拡張機能ガイド |
| [browser-extensions/](browser-extensions/) | ブラウザ拡張機能リスト |

## 参考

- [GitHub does dotfiles](https://dotfiles.github.io/)
