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
| lazygit | `~/.config/lazygit/` | Git TUI設定 |
| ai-prompts | `~/.ai-prompts/` | AIプロンプトテンプレート |

## 非Stow（bootstrap.shで個別処理）

以下はStow管理ではなく、`bootstrap.sh` で特別な処理を行います。

| パッケージ | 理由 | 処理方法 |
|-----------|------|---------|
| **ssh** | セキュリティ上、テンプレート方式を採用 | `config.template` を `~/.ssh/config` にコピー |
| **antigravity** | macOS固有パス（`~/Library/Application Support/`） | `safe_link` で手動リンク |

## コマンド

```bash
# 全パッケージをインストール
make install

# 個別パッケージをインストール
make install-zsh

# ドライラン（変更確認のみ）
make check

# アンインストール
make uninstall
```
