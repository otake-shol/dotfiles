# Stow パッケージ

GNU Stowで管理するdotfilesパッケージの一覧です。

## Stow 管理対象

`make install` または `stow --restow <pkg>` で `$HOME` にシンボリックリンクを作成します。

| パッケージ | 展開先 | 説明 |
|-----------|--------|------|
| zsh | `~/.zshrc`, `~/.zsh/` | シェル設定（モジュール分割） |
| git | `~/.gitconfig` | Git設定・エイリアス |
| nvim | `~/.config/nvim/` | Neovim最小構成 |
| ghostty | `~/.config/ghostty/` | ターミナル設定 |
| bat | `~/.config/bat/` | cat代替ツール設定 |
| atuin | `~/.config/atuin/` | シェル履歴設定 |
| claude | `~/.claude/` | Claude Code設定 |
| gh | `~/.config/gh/` | GitHub CLI設定 |
| yazi | `~/.config/yazi/` | ファイルマネージャー設定 |
| ripgrep | `~/.ripgreprc` | ripgrep設定 |
| direnv | `~/.config/direnv/` | 環境変数管理 |
| cmux | `~/.config/cmux/` | ターミナルマルチプレクサー設定 |

## 非Stow（bootstrap.shで個別処理）

| 対象 | 理由 | 処理方法 |
|------|------|---------|
| SSH | セキュリティ上テンプレート方式 | `scripts/setup/ssh-config.template` → `~/.ssh/config` |

## コマンド

```bash
make install          # 全パッケージをインストール
make install-zsh      # 個別パッケージをインストール
make check            # ドライラン（変更確認のみ）
make uninstall        # アンインストール
```
