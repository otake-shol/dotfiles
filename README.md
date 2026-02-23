# dotfiles

macOS向けの個人開発環境設定ファイル

## 特徴

- **Claude Code完全統合** - セッション管理・MCPサーバー4個・カスタムコマンド
- **モダンCLI** - bat, eza, fd, ripgrep, zoxide, yazi等のモダンツール
- **Vim風操作統一** - yazi, lazygit等でhjkl移動
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
│   ├── yazi/, lazygit/    # ファイラー・Git TUI
│   ├── bat/, atuin/       # ユーティリティ
│   ├── ripgrep/           # ripgrep設定
│   └── ssh/               # SSH設定テンプレート
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
Ctrl+T               # ファイル検索 → コマンドラインに挿入
Alt+C                # ディレクトリ検索 → cd
Ctrl+R               # 履歴検索（atuin）
```

### ファイル操作（yazi）

```bash
y                    # yaziを起動（終了時にcdも反映）
# yazi内: z=zoxide, Z=fzf, e=nvim, b=bat, Y=パスコピー
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

### シェルコマンド

```bash
# 基本
c                    # claude起動
cc                   # 最新セッション続行
co / cs / ch         # Opus / Sonnet / Haiku指定

# セッション管理
cls                  # セッション一覧（fzf選択で再開）
csa                  # 全プロジェクトから検索
csd [日数]           # 古いセッション削除

# ユーティリティ
cq "質問"            # クイック質問（パイプ対応）
cgd                  # git diffをレビュー依頼
```

### キーバインド（Claude Code内）

| キー | 機能 |
|------|------|
| Ctrl+L | 画面クリア |
| Ctrl+R | 最後のリクエスト再試行 |
| Ctrl+Shift+C | 最後の応答をコピー |
| Ctrl+Shift+S | 最後のコマンドをコピー |

### カスタムコマンド

`/commit-push` `/test` `/review` `/spec` `/verify` `/slides` `/worktree` `/learn` `/organize-downloads` `/pc-checkup`

### スライド生成（`/slides`）

Marp CLIでMarkdownからプレゼンスライド（HTML/PDF/PPTX）を生成。Catppuccin Latteベースのカスタムテーマ付き。

- **テンプレート**: チーム計画（半期）、LT（5分/10分）、フリー
- **レイアウトクラス**: `lead` `invert` `columns` `org-chart` `timeline` `metric`

```bash
# Claude Code内で
/slides              # 対話モードでスライド作成

# 直接生成
marp --no-stdin slide.md -o slide.html --theme ~/.claude/commands/slides-theme.css
```

### 特化型エージェント

code-reviewer, test-engineer, frontend-engineer, architecture-reviewer, spec-analyst

### MCPサーバー（5個）

Context7, Serena, Playwright, Atlassian, Figma

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
