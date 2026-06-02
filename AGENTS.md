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
make validate    # lint＋README整合＋構文＋絶対パス/local-state混入検査
```

## 規約

- **シェルスクリプト**: `#!/bin/bash` + `set -euo pipefail`、`local` 宣言、ShellCheck 準拠
- **コミット**: Conventional Commits（`feat`, `fix`, `docs`, `refactor`, `chore` 等）。日本語本文OK
- **ブランチ**: `master` 直接コミット可（個人リポジトリ）
- **フォーマッタ**: shfmt（シェル）、Prettier（JSON/MD）

## 変更時のルール（コミット前に必ず）

リポジトリに変更を加えたら、**コミット前に `make validate` を通す**。validate は lint・README整合・TOML/JSON/.mjs 構文・絶対パス混入・Codex local-state 混入をまとめて検査する。

- **修正対象だけ直して終わりにしない。** その変更が波及する派生物（README の件数、構文、リンク等）も同じコミットで揃える
- validate が落ちたら、出力に表示される**修復コマンドを実行してから**コミットする
  - 例: Brewfile のパッケージを増減 → `make readme-sync`（README のパッケージ件数を同期）
  - 例: stow パッケージを増減 → `make readme-sync`（同上）
- 「変更 → validate → 落ちたら修復 → 再 validate → green を確認 → commit」を1セットとする

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
