# dotfiles

macOS向けの個人開発環境設定ファイル

## クイックスタート

```bash
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash bootstrap.sh
```

## 構成

```
dotfiles/
├── stow/              # GNU Stowパッケージ（12個）
│   ├── zsh/           # シェル設定（モジュール分割）
│   ├── git/, gh/      # Git/GitHub CLI
│   ├── claude/        # Claude Code
│   ├── ghostty/, cmux/ # ターミナル
│   ├── nvim/          # エディタ
│   ├── bat/, atuin/   # ユーティリティ
│   ├── yazi/          # ファイラー
│   ├── ripgrep/       # 検索
│   └── direnv/        # 環境変数
├── Brewfile           # Homebrewパッケージ
├── Makefile           # Stow操作
└── bootstrap.sh       # 自動セットアップ
```

## コマンド

```bash
make install           # 全Stowパッケージをインストール
make check             # Stowドライラン
make lint              # ShellCheck
```

## モダンCLI

| 従来 | 代替 | 説明 |
|------|------|------|
| cat | bat | ハイライト付き表示 |
| ls | eza | アイコン+Git状態 |
| grep | ripgrep | 高速検索 |
| find | fd | 高速ファイル検索 |
| cd | zoxide | 学習型ジャンプ |
| history | atuin | SQLite履歴 |

## キーバインド

| キー | 機能 |
|------|------|
| Ctrl+T | fzfファイル検索 |
| Alt+C | fzfディレクトリ移動 |
| Ctrl+R | atuin履歴検索 |

## Claude Code

```bash
c / co / cs / ch       # 起動（デフォルト/Opus/Sonnet/Haiku）
cc                     # 最新セッション続行
cls                    # セッション一覧
```

## テーマ

全ツールで **TokyoNight** に統一（Ghostty, bat, fzf, yazi, Neovim）

## トラブルシューティング

### コマンドが見つからない

```bash
functions claude           # 関数定義を確認
source ~/.zsh/lazy.zsh     # 手動読み込み
```

`ZSH_CONFIG_DIR`がunsetされていないか確認。

### シンボリックリンクの修復

```bash
cd ~/dotfiles && stow --restow --target=$HOME --dir=stow zsh
```

### Apple Watch sudo認証が効かない（macOSアップデート後）

```bash
cat /etc/pam.d/sudo_local   # 設定確認
bash bootstrap.sh            # 再セットアップ
```
