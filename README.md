# dotfiles

macOS/Linux向けの個人開発環境設定ファイル

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
├── antigravity/           # エディタ設定（※後述）
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

> **Note**: `antigravity/` はmacOS固有パス（`~/Library/Application Support/`）を使用するため、GNU Stowではなく`bootstrap.sh`で個別にリンクを作成しています。

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

## トラブルシューティング

### Homebrewのパスが通らない

```bash
# Apple Silicon Mac
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Mac
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
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

## セットアップ確認チェックリスト

- [ ] `brew --version` が動作する
- [ ] `ls ~/.oh-my-zsh` でディレクトリが存在する
- [ ] `git config --list` で設定が反映されている
- [ ] `gh auth status` でログイン済み
- [ ] `asdf --version` が動作する

> 詳細なアプリケーション説明は [APPS.md](docs/setup/APPS.md) を参照

## バージョン管理 (asdf)

Node.js, Python, Ruby等のランタイムは[asdf](https://asdf-vm.com/)で管理しています。

```bash
# バージョン確認
asdf current

# プラグイン追加・バージョンインストール
asdf plugin add nodejs
asdf install nodejs latest
asdf global nodejs latest
```

設定ファイル: `stow/zsh/.tool-versions`

> **Note**: asdfは遅延読み込みされるため、初回のnode/npm実行時に自動で初期化されます。

## Git Hooks (lefthook)

[lefthook](https://github.com/evilmartians/lefthook)でpre-commit/commit-msgフックを管理しています。

```bash
# 初回セットアップ（bootstrap.shで自動実行）
lefthook install

# 手動でフック実行
lefthook run pre-commit
```

**設定済みフック:**
- ShellCheck, yamllint, markdownlint
- zsh構文チェック
- Conventional Commits形式チェック
- 末尾空白・secrets検出

設定ファイル: `lefthook.yml`

## Claude Code統合

Claude Codeの設定は `stow/claude/` で管理しています。

```
stow/claude/.claude/
├── CLAUDE.md           # 開発ガイドライン・MCP設定
├── settings.json       # hooks, permissions
├── commands/           # カスタムスラッシュコマンド
│   ├── commit-push.md  # /commit-push
│   ├── test.md         # /test
│   └── review.md       # /review
└── agents/             # 特化型エージェント
    ├── code-reviewer.md
    └── test-engineer.md
```

**MCPサーバー（13個設定済み）:**
- Context7, Serena, Playwright, Sequential Thinking
- Linear, Supabase, Notion, Figma, Slack (OAuth)
- GitHub, Brave Search, Sentry (環境変数)

## 動作環境

- macOS 12.0+ (Monterey以降)
- Linux (Ubuntu 20.04+, Debian 11+)
- WSL2 (Windows Subsystem for Linux)

## 参考リンク

- [GitHub does dotfiles](https://dotfiles.github.io/) - dotfiles管理のベストプラクティス
- [Modern Unix](https://github.com/ibraheemdev/modern-unix) - モダンCLIツール一覧
