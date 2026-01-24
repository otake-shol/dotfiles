# dotfiles

macOS/Linux向けの個人開発環境設定ファイル

[![Lint](https://github.com/otake-shol/dotfiles/actions/workflows/lint.yml/badge.svg)](https://github.com/otake-shol/dotfiles/actions/workflows/lint.yml)

## 特徴

- **Claude Code統合** - MCPサーバー13個・カスタムコマンド設定済み
- **モダンCLI** - bat, eza, fzf, ripgrep, zoxide等のモダンツール
- **自動セットアップ** - bootstrap.shで一発構築
- **テーマ統一** - 全ツールでTokyoNightテーマ
- **高速起動** - 遅延読み込みによるzsh起動時間最適化

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

## ディレクトリ構成

```
dotfiles/
├── stow/                  # GNU Stowパッケージ
│   ├── zsh/               # シェル設定（モジュール分割）
│   │   ├── .zshrc         # メイン設定
│   │   └── .zsh/          # モジュール群
│   │       ├── core.zsh   # 基本設定
│   │       ├── lazy.zsh   # 遅延読み込み
│   │       ├── tools.zsh  # ツール設定
│   │       ├── plugins.zsh # Oh My Zsh
│   │       └── aliases/   # エイリアス
│   ├── git/, gh/          # Git/GitHub CLI設定
│   ├── claude/            # Claude Code (agents, commands, hooks)
│   ├── nvim/              # Neovim（最小構成）
│   ├── ghostty/           # ターミナル設定
│   ├── bat/, atuin/       # ユーティリティ設定
│   └── ssh/               # SSH設定テンプレート
├── antigravity/           # エディタ設定（Stow対象外）
├── scripts/               # ユーティリティスクリプト
│   ├── setup/             # OS別セットアップ
│   ├── maintenance/       # メンテナンススクリプト
│   ├── utils/             # ユーティリティ
│   └── lib/               # 共通ライブラリ
├── docs/                  # ドキュメント
├── Brewfile               # Homebrewパッケージ一覧
├── Makefile               # Stow操作・開発コマンド
└── bootstrap.sh           # 自動セットアップスクリプト
```

## 便利なコマンド

### ヘルプ・情報

```bash
dothelp              # エイリアス一覧・使い方
dotverify            # セットアップ状態の検証
dotsysinfo           # システム情報表示
```

### メンテナンス

```bash
dotupdate            # 全ツール一括更新
dotup                # 更新チェック
brewsync             # Brewfile同期チェック
```

### fzf連携

```bash
fvim                 # ファイル選択 → nvimで開く
fbr                  # ブランチ選択 → checkout
fshow                # コミット履歴ブラウズ
fkill                # プロセス選択 → kill
fcd                  # ディレクトリ選択 → cd
```

### SSH鍵管理

```bash
dotssh               # SSH鍵セットアップ（対話式）
dotsshlist           # SSH鍵一覧表示
```

## モダンCLI対応表

| 従来コマンド | モダン代替 | 説明 |
|-------------|-----------|------|
| cat | bat | シンタックスハイライト付き表示 |
| ls | eza | アイコン・Git状態表示 |
| grep | rg (ripgrep) | 高速正規表現検索 |
| find | fd | 高速ファイル検索 |
| cd | zoxide | 学習型ディレクトリジャンプ |
| history | atuin | SQLite履歴・同期対応 |

## 開発コマンド (Makefile)

```bash
make install         # 全Stowパッケージをインストール
make uninstall       # 全Stowパッケージをアンインストール
make check           # ドライラン（変更プレビュー）
make lint            # ShellCheck実行
make health          # lint + check
make bench           # zsh起動時間ベンチマーク
make deps            # Homebrewパッケージインストール
```

## ドキュメント

| ファイル | 内容 |
|---------|------|
| [SETUP.md](docs/setup/SETUP.md) | 詳細セットアップ手順 |
| [APPS.md](docs/setup/APPS.md) | アプリケーション説明一覧 |

## 動作環境

- macOS 12.0+ (Monterey以降)
- Linux (Ubuntu 20.04+, Debian 11+)
- WSL2 (Windows Subsystem for Linux)

## 参考リンク

- [GitHub does dotfiles](https://dotfiles.github.io/) - dotfiles管理のベストプラクティス
- [Modern Unix](https://github.com/ibraheemdev/modern-unix) - モダンCLIツール一覧
