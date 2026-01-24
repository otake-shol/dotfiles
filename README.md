# dotfiles

macOS向けの個人開発環境設定ファイル

[![Lint](https://github.com/otake-shol/dotfiles/actions/workflows/lint.yml/badge.svg)](https://github.com/otake-shol/dotfiles/actions/workflows/lint.yml)

## 特徴

- **Claude Code統合** - MCPサーバー・カスタムコマンド設定済み
- **モダンCLI** - bat, eza, fzf, ripgrep, zoxide等
- **自動セットアップ** - bootstrap.shで一発構築
- **テーマ統一** - 全ツールでTokyoNight

## クイックスタート

```bash
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash bootstrap.sh
```

### オプション

```bash
bash bootstrap.sh --help        # ヘルプ表示
bash bootstrap.sh --dry-run     # 変更プレビュー（実行しない）
bash bootstrap.sh --skip-apps   # アプリインストールをスキップ
```

## 構成

```
dotfiles/
├── stow/                  # GNU Stowパッケージ
│   ├── zsh/               # シェル設定
│   ├── git/, gh/          # Git/GitHub CLI
│   ├── claude/            # Claude Code (agents, commands)
│   ├── nvim/              # Neovim（最小構成）
│   ├── ghostty/           # ターミナル
│   ├── bat/, atuin/       # ユーティリティ
│   └── ssh/               # SSH設定
├── antigravity/           # エディタ設定
├── scripts/               # ユーティリティスクリプト
├── Brewfile               # Homebrewパッケージ
└── bootstrap.sh           # セットアップスクリプト
```

## 便利なコマンド

```bash
# ヘルプ・情報
dothelp              # エイリアス一覧
dotverify            # セットアップ検証

# メンテナンス
dotupdate            # 全ツール更新
brewsync             # Brewfile同期チェック

# fzf連携
fvim                 # ファイル選択 → nvim
fbr                  # ブランチ選択 → checkout
fshow                # コミット履歴ブラウズ
```

## モダンCLI

| 従来 | モダン | 説明 |
|------|--------|------|
| cat | bat | シンタックスハイライト |
| ls | eza | アイコン・Git連携 |
| grep | rg | 高速検索 |
| find | fd | 高速ファイル検索 |
| cd | zoxide | スマートジャンプ |

## ドキュメント

| ファイル | 内容 |
|---------|------|
| [SETUP.md](docs/setup/SETUP.md) | 詳細セットアップ手順 |
| [APPS.md](docs/setup/APPS.md) | アプリケーション一覧 |

## 動作環境

- macOS 12.0+
- Linux (Ubuntu 20.04+, Debian 11+)
- WSL2

## 参考

- [GitHub does dotfiles](https://dotfiles.github.io/)
- [Modern Unix](https://github.com/ibraheemdev/modern-unix)
