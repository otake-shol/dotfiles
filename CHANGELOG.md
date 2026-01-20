# Changelog

このdotfilesの変更履歴を記録します。

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
