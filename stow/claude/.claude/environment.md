# 環境・技術設定

CLAUDE.md から分離した技術スタック、ツール設定、開発環境の詳細。

---

## 技術スタック

- React / Next.js / TypeScript（厳格モード推奨）
- Node.js（.tool-versionsで管理）/ Java（API開発）
- パッケージマネージャー: プロジェクトのlock fileに従う
- Gitフロー: git-flow基本、個人開発はmasterへの直接プッシュもOK

---

## コードスタイル

- 命名規則・型定義: プロジェクトの既存ルールに従う
- コメント: 関数やコンポーネントにはJSDocを書く
- コミットメッセージ: **Conventional Commits**（feat, fix, docs, refactor, test, chore等）

---

## テスト

- **Vitest**（推奨）/ Jest / React Testing Library / Playwright（E2E）
- 意味のないアサーション禁止、ハードコード禁止、`if (testMode)` 禁止
- Red-Green-Refactor で進める

---

## Hooks・スクリプト

| Hook | イベント | 用途 |
|------|---------|------|
| auto-format.sh | PostToolUse (Edit\|Write) | Prettier/shfmtで自動フォーマット |
| notify.sh | Notification | cmux/macOS通知 |
| 完了検証 | Stop | 変更の完全性を停止前に検証 |
| コンテキスト保存 | PreCompact | コンパクション前に重要情報を要約 |

手動: `verify.sh`（型+Lint+テスト）、`update-brewfile.sh`

---

## パーミッション

`Bash(*)` 全許可 + deny/askでゲート。詳細は `settings.json` を参照。

- **deny**: .env/credentials/SSH鍵の読み取り、rm -rf、sudo、curl|sh
- **ask**: git push/reset --hard/rebase、curl/wget、npm publish

---

## MCPサーバー

| サーバー | 用途 |
|---------|------|
| Context7 | ドキュメント参照（確認不要で自動利用） |
| Playwright | ブラウザ自動化・E2Eテスト |
| GitHub | Issue/PR操作（OAuth） |
| gws | Gmail/Drive/Calendar等（OAuth: `gws auth setup`） |
| hourei | e-Gov法令検索・条文取得 |
| tax-law | 税法・通達・裁決事例 |

セットアップ: `~/.claude/setup.sh`

---

## プラグイン・エージェント

- **superpowers**: TDD、コードレビュー、デバッグ、計画作成等
- **claude-mem**: 会話間の記憶保持
- エージェント: superpowers/ビルトイン提供のものを使用

---

## dotfiles 開発

```
dotfiles/
├── bootstrap.sh           # セットアップスクリプト
├── Makefile               # GNU Stow操作
├── Brewfile               # Homebrewパッケージ
└── stow/                  # GNU Stowパッケージ（10個）
```

```bash
make lint                  # ShellCheck実行
make check                 # ドライラン
make install               # 全パッケージインストール
```

シェルスクリプト規約: `#!/bin/bash` + `set -euo pipefail`、`local`宣言、ShellCheck準拠
