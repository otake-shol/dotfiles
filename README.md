# dotfiles

個人用の設定ファイル管理リポジトリ

## クイックスタート

```bash
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash bootstrap.sh
```

## 構成

```
dotfiles/
├── .zshrc, .aliases     # シェル設定
├── Brewfile             # 必須アプリ
├── Brewfile.full        # 全アプリ
├── bootstrap.sh         # 自動セットアップ
├── .claude/             # Claude Code設定
├── git/                 # Git設定
├── gh/                  # GitHub CLI設定
├── ghostty/             # ターミナル設定
├── antigravity/         # Antigravity設定
└── docs/                # ドキュメント
```

## ドキュメント

- [SETUP.md](docs/SETUP.md) - 詳細セットアップ手順
- [APPS.md](docs/APPS.md) - アプリケーション一覧

## 参考情報

- [GitHub does dotfiles](https://dotfiles.github.io/) - dotfiles管理のベストプラクティス、ツール、チュートリアル集
