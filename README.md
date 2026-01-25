# dotfiles

macOS向けの個人開発環境設定ファイル

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

### セットアップ確認

```bash
dotverify                       # 自動検証（推奨）
```

手動確認：
- [ ] `brew --version` が動作する
- [ ] `ls ~/.oh-my-zsh` でディレクトリが存在する
- [ ] `git config --list` で設定が反映されている
- [ ] `gh auth status` でログイン済み

## ディレクトリ構成

```
dotfiles/
├── stow/                  # GNU Stowパッケージ
│   ├── zsh/               # シェル設定（モジュール分割）
│   ├── git/, gh/          # Git/GitHub CLI設定
│   ├── claude/            # Claude Code設定
│   ├── nvim/, ghostty/    # エディタ・ターミナル
│   ├── bat/, atuin/       # ユーティリティ
│   ├── ssh/               # SSH設定テンプレート
│   └── antigravity/       # Antigravity拡張機能
├── scripts/               # ユーティリティスクリプト
├── docs/                  # 詳細ドキュメント
├── Brewfile               # Homebrewパッケージ一覧
├── Makefile               # Stow操作・開発コマンド
└── bootstrap.sh           # 自動セットアップスクリプト
```

> **Note**: `stow/ssh/`と`stow/antigravity/`はテンプレート方式のため、`bootstrap.sh`で個別処理しています。

## 便利なコマンド

### ヘルプ・メンテナンス

```bash
dothelp              # エイリアス一覧・使い方
dotverify            # セットアップ状態の検証
dotupdate            # 全ツール一括更新
brewsync             # Brewfile同期チェック
```

### fzf連携

```bash
fvim                 # ファイル選択 → nvimで開く
fbr                  # ブランチ選択 → checkout
fshow                # コミット履歴ブラウズ
fkill                # プロセス選択 → kill
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

## 開発

### Makefile

```bash
make install         # 全Stowパッケージをインストール
make uninstall       # 全Stowパッケージをアンインストール
make lint            # ShellCheck実行
make bench           # zsh起動時間ベンチマーク
```

### Git Hooks (lefthook)

pre-commit時にShellCheck、yamllint、zsh構文チェックを自動実行。
コミットメッセージはConventional Commits形式を強制。

```bash
lefthook install     # 初回セットアップ（bootstrap.shで自動実行）
```

### バージョン管理 (asdf)

Node.js等のランタイムは[asdf](https://asdf-vm.com/)で管理。遅延読み込みにより初回実行時に自動初期化。

## Claude Code統合

設定ファイル: `stow/claude/.claude/`

> 外出先からの操作は [docs/remote-access.md](docs/remote-access.md) を参照

**カスタムコマンド:**
- `/commit-push` - コミット＆プッシュ
- `/test` - テスト生成
- `/review` - コードレビュー
- `/spec` - 仕様レビュー
- `/organize-downloads` - ダウンロードフォルダ整理
- `/pc-checkup` - PC健康診断

**特化型エージェント:**
- code-reviewer, test-engineer
- frontend-engineer, architecture-reviewer, spec-analyst

**MCPサーバー（13個）:**
- Context7, Serena, Playwright, Sequential Thinking
- Linear, Supabase, Notion, Figma, Slack (OAuth)
- GitHub, Brave Search, Sentry (環境変数)

## トラブルシューティング

> 詳細な診断手順は [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) を参照

### Homebrewのパスが通らない

```bash
# Apple Silicon Mac
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Mac
eval "$(/usr/local/bin/brew shellenv)"
```

### Oh My Zshのテーマが表示されない

1. Nerd Fontがインストールされているか確認: `brew list --cask | grep nerd-font`
2. ターミナルのフォント設定を確認（Ghostty: `font-family`）

### シンボリックリンクエラー

```bash
mv ~/.zshrc ~/.zshrc.backup  # バックアップ
cd ~/dotfiles && make install-zsh
```

## 動作環境

- macOS 12.0+ (Monterey以降)

## 参考リンク

- [GitHub does dotfiles](https://dotfiles.github.io/) - dotfiles管理のベストプラクティス
- [Modern Unix](https://github.com/ibraheemdev/modern-unix) - モダンCLIツール一覧

> 詳細なアプリケーション説明は [docs/setup/APPS.md](docs/setup/APPS.md) を参照
