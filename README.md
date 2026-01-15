# dotfiles

macOS用の個人設定ファイル

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
| `bat/` | bat設定 |
| `raycast/` | Raycastスクリプト |
| `antigravity/` | Antigravity設定 |
| `browser-extensions/` | ブラウザ拡張機能リスト |
| `scripts/` | ユーティリティスクリプト |
| `templates/` | 仕様・ドキュメントテンプレート |
| `espanso/` | テキスト展開（AIプロンプトスニペット） |

## ドキュメント

### AI駆動開発（推奨）
| ファイル | 内容 |
|---------|------|
| [AI-DRIVEN-DEV-GUIDE.md](docs/AI-DRIVEN-DEV-GUIDE.md) | AI駆動開発環境 完全ガイド |
| [SPEC-DRIVEN-DEV.md](docs/SPEC-DRIVEN-DEV.md) | 仕様駆動開発ガイド |
| [AI-PROMPTS.md](docs/AI-PROMPTS.md) | AIプロンプトテンプレート集 |
| [mcp-servers-guide.md](docs/mcp-servers-guide.md) | MCPサーバー設定ガイド |

### セットアップ・ツール
| ファイル | 内容 |
|---------|------|
| [SETUP.md](docs/SETUP.md) | 詳細セットアップ手順 |
| [APPS.md](docs/APPS.md) | アプリケーション一覧 |
| [BROWSER_EXTENSIONS.md](docs/BROWSER_EXTENSIONS.md) | ブラウザ拡張機能 |
| [DOTFILES_MANAGER.md](docs/DOTFILES_MANAGER.md) | dotfiles管理ツール比較 |
| [antigravity-extensions.md](docs/antigravity-extensions.md) | Antigravity拡張機能ガイド |
| [vim-mastery-roadmap.md](docs/vim-mastery-roadmap.md) | Vim習得ロードマップ |

## 参考

- [GitHub does dotfiles](https://dotfiles.github.io/)
