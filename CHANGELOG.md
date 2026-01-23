# Changelog

このdotfilesの変更履歴を記録します。

## [2026-01-24] - 整理・統一

### Changed
- バージョン管理を **asdf に統一**（nvm, pyenv, tfenv から移行推奨）
- `.tool-versions` に terraform 追加
- Docker Desktop → OrbStack 移行完了
- iterm2 プラグイン削除（Ghostty 使用）

### Removed
- `zellij/` - tmux に統一
- `ghostty/shaders/` - 未使用
- `templates/specs/` - 未使用
- `docs/learning/vim-mastery-roadmap.md` - Vim 不使用
- `docs/tools/BROWSER_EXTENSIONS.md` - browser-extensions/ に統合

### Fixed
- README.md の削除済みファイル参照を修正
- bootstrap.sh のシェーダーリンク削除
- SETUP.md の nvm 手順削除

---

## [Unreleased]

### Added
- `ssh/config` - セキュアなSSH設定
- `git/.gitignore_global` - グローバルignore
- `.editorconfig` - エディタ間フォーマット統一
- `.tool-versions` - asdfデフォルトバージョン
- `scripts/check-updates.sh` - 更新チェックスクリプト
- tmux-resurrect/continuum - セッション保存・復元
- gh CLIエイリアス拡充（prc, prv, prm等）
- Git設定強化（fsmonitor, untrackedCache, manyFiles）
- zsh履歴拡張（50000件）、Ctrl+Zトグル

### Changed
- batテーマをTokyoNightに統一
- README.mdにテーマ統一・ツール使い分けを明記

---

## [2025-01-21] - 推奨設定追加

### Added
- Git設定強化（rebase, rerere, prune等）
- macOS defaults拡充（Dock, Finder, キーボード, トラックパッド）
- モダンCLIツール（dust, procs, sd, hyperfine, git-absorb）
- 対応エイリアス追加

---

## [Initial] - 初期構成

### Included
- zsh設定（Oh My Zsh + Powerlevel10k）
- Neovim設定（ミニマル）
- tmux設定（TokyoNight風）
- Ghostty設定
- Git設定（delta, git-secrets）
- Claude Code統合（MCPサーバー13個）
- Brewfile（必須/全ツール）
- bootstrap.sh（自動セットアップ）
