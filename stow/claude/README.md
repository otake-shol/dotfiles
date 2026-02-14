# claude パッケージ

Claude Code の設定ファイル一式。GNU Stow でホームディレクトリに展開される。

## ディレクトリ構成

```
stow/claude/
├── .claude/                          # → ~/.claude/
│   ├── CLAUDE.md                     # グローバル指示書（開発哲学・スタンス）
│   ├── environment.md                # 技術スタック・ツール設定
│   ├── settings.json                 # パーミッション・hooks・ステータスライン設定
│   ├── keybindings.json              # キーバインド設定
│   ├── setup.sh                      # MCP サーバー初期セットアップ
│   ├── statusline.sh                 # ステータスライン表示スクリプト
│   ├── statusline-command.sh         # ステータスライン用コマンド
│   ├── validate.sh                   # 環境検証スクリプト
│   ├── .claude/                      # ネストされた設定（下記参照）
│   │   └── settings.local.json       # ローカル専用設定（.gitignore 対象）
│   ├── agents/                       # カスタムエージェント定義
│   ├── commands/                     # スラッシュコマンド定義
│   ├── hooks/                        # 自動実行フック
│   │   ├── auto-format.sh            # PostToolUse: 編集後の自動フォーマット
│   │   ├── notify.sh                 # Notification: macOS 通知
│   │   ├── update-brewfile.sh        # brew install 後の Brewfile 自動更新
│   │   └── verify.sh                 # 型チェック + Lint + テスト一括実行
│   ├── plugins/                      # プラグイン設定
│   │   └── marketplaces.json.template
│   └── scripts/                      # 補助スクリプト
│       └── auto-update.sh            # 自動アップデート（LaunchAgent 連携）
└── Library/
    └── LaunchAgents/
        └── com.claude-code.auto-update.plist  # → ~/Library/LaunchAgents/
```

## ネスト構造について

`~/.claude/.claude/settings.local.json` は Claude Code がプロジェクト固有の自動許可設定を保存するファイル。
`~/.claude/settings.json`（Stow 管理）とは別に、ローカルで自動生成される設定を分離している。
`.gitignore` で除外済み。

## セットアップ

```bash
# dotfiles の一部として Stow でインストール
make install

# Claude Code 単独でセットアップ（MCP サーバー等）
~/.claude/setup.sh

# 環境の検証
~/.claude/validate.sh
```
