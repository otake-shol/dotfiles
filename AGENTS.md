# AGENTS.md

dotfiles リポジトリ。macOS 環境を GNU Stow + Homebrew + Claude Code で再現する個人設定。

## 構成

```
dotfiles/
├── bootstrap.sh       # 初回セットアップ
├── Makefile           # Stow 操作（install/check/lint/doctor）
├── Brewfile           # Homebrew パッケージ定義
└── stow/              # Stow パッケージ（claude/ghostty/zsh など）
```

各 `stow/<pkg>/` 配下の構造は `$HOME` にミラーされる。`stow/claude/.claude/` → `~/.claude/`。

## 開発コマンド

```bash
make lint        # ShellCheck 実行
make check       # Stow ドライラン
make install     # 全パッケージインストール
make doctor      # stow 同期＋壊れリンク検出
```

## 規約

- **シェルスクリプト**: `#!/bin/bash` + `set -euo pipefail`、`local` 宣言、ShellCheck 準拠
- **コミット**: Conventional Commits（`feat`, `fix`, `docs`, `refactor`, `chore` 等）。日本語本文OK
- **ブランチ**: `master` 直接コミット可（個人リポジトリ）
- **フォーマッタ**: shfmt（シェル）、Prettier（JSON/MD）

## 触ってはいけないもの

- `.env`, `*credentials*`, `*.key`, `~/.ssh/` 配下のファイルは読み書き禁止
- `1Password` 関連の設定（外部ツール管理）
- `stow/claude/.claude/settings.json` の `permissions` セクションは慎重に（hooks/MCP が壊れる）

## 危険な操作（実行前に必ず確認を取る）

- `rm -rf`, `git reset --hard`, `git push --force`
- `brew uninstall`（Brewfile の同期が崩れる）
- `stow -D`（シンボリックリンク削除）

## このリポジトリで多い作業

- Brewfile へのパッケージ追加／コメント整理
- `stow/<pkg>/` 配下の設定ファイル編集
- `Makefile` ターゲット追加
- Claude Code / Codex 用設定（hooks, MCP, AGENTS.md, CLAUDE.md）の調整

## 関連

- 詳細な開発者向け規約は `.claude/CLAUDE.md` および `~/.claude/environment.md` を参照（Claude Code 利用時の追加コンテキスト）
