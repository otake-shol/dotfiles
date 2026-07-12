# 環境・技術設定

CLAUDE.md から分離した技術スタック、ツール設定、開発環境の詳細。

---

## 技術スタック

- React / Next.js / TypeScript（厳格モード推奨）
- Node.js / Java（API開発）
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
| cmux claude-hook | SessionStart / Stop | cmuxへのセッション開始・終了通知 |
| プロンプト型 | PreCompact | コンパクション前に重要情報を要約 |

完了検証（verify）は Stop hook ではなく、各リポジトリの `npm run verify` ＋ CI で担保（engineering-quality.md 参照）。

手動: `verify.sh`（型+Lint+テスト）、`update-brewfile.sh`

---

## パーミッション

`Bash(*)` 全許可 + deny/askでゲート。詳細は `settings.json` を参照。

- **deny**: .env/credentials/SSH鍵の読み取り、rm -rf、sudo、curl|sh
- **ask**: git push --force/-f、git reset --hard/rebase/clean、curl/wget、npm publish（通常の git push は許可）

---

## MCPサーバー

設定済み（user スコープ、定義は `~/.claude.json` = dotfiles 管理外。新マシンでは下記コマンドで再現）:

| サーバー | 用途 | 再現コマンド |
|---------|------|-------------|
| context7 | ドキュメント参照 | `claude mcp add -s user context7 -- npx -y @upstash/context7-mcp` |
| playwright | ブラウザ自動化・E2Eテスト | `claude mcp add -s user playwright -- npx -y @playwright/mcp@latest` |

Gmail / Google Calendar / Google Drive は claude.ai 側コネクタで接続済み（旧 gws MCP の代替）。
GitHub 操作は `gh` CLI を使用（旧 GitHub MCP の代替）。

過去に使っていた未再導入サーバー（必要になったら `claude mcp add` し、コマンドをここに追記）:
hourei（e-Gov法令検索）/ tax-law（税法・通達・裁決事例）/ mf-ca（マネーフォワード クラウド会計、リモートMCP・OAuth）

---

## プラグイン・エージェント

- **vercel**（claude-plugins-official）: Next.js/Vercel 関連スキル約30個。スキルのメタデータは毎セッション読み込まれるため、従量課金では固定コスト要因。不要になったら `/plugin` で無効化を検討
- ※ superpowers / claude-mem は marketplace ごと消失済み（settings.json の enabledPlugins に stale エントリが残存）
- エージェント: ビルトイン（Explore/Plan 等）＋ `~/.claude/agents/` のカスタムエージェント
  - **explore-lite**: haiku 固定の読み取り専用検索。単純な探索・grep はこちらに委譲してコスト削減

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
