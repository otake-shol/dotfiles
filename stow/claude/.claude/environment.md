# 環境・技術設定

CLAUDE.md から分離した技術スタック、ツール設定、開発環境の詳細。

---

## 技術スタック

### メイン技術
- React / Next.js
- TypeScript（厳格モード推奨）
- Node.js（.tool-versionsで管理）
- Java（API開発）

### パッケージマネージャー
- npm / yarn / pnpm いずれも可
- プロジェクトのlock fileに従う

### Gitフロー
- 基本は **git-flow** に従う（feature/develop/release/hotfix/master）
- 個人開発で工数削減したい場合は、masterブランチへの直接プッシュもOK

---

## コードスタイル

- 命名規則・TypeScriptの型定義: プロジェクトの既存ルールに従う
- コメント: 関数やコンポーネントにはJSDocを書く
- ディレクトリ構成: レイヤーベース（components, hooks, utils など）を好む
- コミットメッセージ: **Conventional Commits**（feat, fix, docs, style, refactor, perf, test, chore, ci）

---

## テスト

### フレームワーク
- **Vitest**（推奨）または **Jest**
- React コンポーネント: **React Testing Library**
- E2E: **Playwright**

### 厳守事項
- テストは必ず実際の機能を検証する
- `expect(true).toBe(true)` のような意味のないアサーション禁止
- テストを通すためだけのハードコード禁止
- 本番コードに `if (testMode)` のような条件分岐を入れない
- Red-Green-Refactor で進める

---

## Hooks設定

| Hook | イベント | タイプ | 用途 |
|------|---------|--------|------|
| 安全性チェック | PreToolUse (Write\|Edit) | prompt | システムパス・機密情報の書き込み防止 |
| auto-format.sh | PostToolUse (Edit\|Write) | command | ファイル編集後に自動フォーマット |
| notify.sh | Notification | command | macOS通知でタスク完了を通知 |
| 完了検証 | Stop | prompt | 変更の完全性を停止前に検証 |
| コンテキスト保存 | PreCompact | prompt | コンパクション前に重要情報を要約 |

### ユーティリティスクリプト（手動実行）
| スクリプト | 用途 |
|-----------|------|
| verify.sh | 型チェック + Lint + テスト一括実行（`/verify` コマンドから呼出） |
| update-brewfile.sh | Brewfile自動更新 |

### auto-format.sh の対応形式
- **Prettier**: js, jsx, ts, tsx, json, md, css, scss, html, yaml, yml
- **shfmt**: sh, bash
- **black + isort**: py
- **rustfmt**: rs
- **gofmt**: go

---

## パーミッション設定

### 設計方針
`Bash(*)` で全コマンドを許可し、**deny/ask で危険な操作をゲート**する方式。
摩擦を最小化しつつ、破壊的操作・機密アクセス・外部通信は確実にブロック/確認する。

### 自動許可（allow）
- `Bash(*)` — 全シェルコマンド（deny/ask で除外されるもの以外）
- ファイル操作: `Read`, `Edit`, `Write`, `Glob`, `Grep`
- スキル/タスク: `Skill(*)`, `Task(*)`
- Web: `WebFetch(*)`, `WebSearch(*)`
- MCP: `mcp__playwright__*`, `mcp__context7__*`, `mcp__serena__*`, `mcp__gws__*`

### 自動拒否（deny）
- `.env*`, `credentials*`, `*secret*` の読み取り
- `~/.ssh/**`, `~/.gnupg/**`, `~/.aws/**`, `~/.kube/**`, `~/.npmrc` の読み取り
- `~/.bashrc`, `~/.zshrc`, `~/.zprofile` の編集
- `rm -rf *`, `rm -r *`（再帰削除は一律ブロック）
- `sudo *`
- `curl/wget * | sh/bash`（パイプ実行）

### 確認が必要（ask）
- `git push *`（force含む）
- `git reset --hard*`
- `git checkout .`, `git checkout -- *`
- `git clean *`
- `git rebase *`
- `curl *`, `wget *`（外部通信は都度確認）
- `npm publish *`, `npm unpublish *`

### サンドボックス
- **無効**: プロキシ環境でのTLS競合を回避するため廃止（2026-03-14）
- `disableBypassPermissionsMode: "disable"` - bypass モード無効化
- セキュリティは deny/ask ルールで確保

---

## Apple / Google ストア共通設定

プロジェクト固有の CLAUDE.md に Apple ID・Team ID 等を記載すること。

| 設定 | 配置場所 |
|------|---------|
| Apple ID / Team ID | プロジェクトの `.claude/CLAUDE.md` |
| Google Play サービスアカウントキー | `./google-play-service-account.json`（プロジェクトルート） |
| ASC App ID | アプリごとに異なる |

### App Store スクリーンショットサイズ

| デバイス | サイズ（縦） | サイズ（横） |
|---------|------------|------------|
| iPhone 6.5インチ | 1242 × 2688 | 2688 × 1242 |
| iPhone 6.7インチ | 1284 × 2778 | 2778 × 1284 |

スクリーンショットの配置先: `assets/screenshots/{6.5inch,6.7inch}/`

---

## MCPサーバー

| サーバー | 用途 | 認証 |
|---------|------|------|
| Context7 | リアルタイムドキュメント参照 | 不要 |
| Serena | シンボリックコード解析（LSP統合） | 不要 |
| Playwright | ブラウザ自動化・E2Eテスト | 不要 |
| Atlassian | Jira/Confluence操作 | 不要 |
| Figma | デザイン→コード変換 | OAuth |
| gws | Gmail/Drive/Calendar/Sheets/Docs操作 | OAuth（`gws auth setup`） |

### 利用ルール
- **Context7**: 確認不要。ドキュメント参照が必要な場面で自動的に利用する

### セットアップ
```bash
~/.claude/setup.sh
```

---

## プラグイン

### インストール済み
| プラグイン | マーケットプレイス | 用途 |
|-----------|-------------------|------|
| superpowers | obra/superpowers-marketplace | TDD、コードレビュー、デバッグ等 |
| claude-mem | thedotmack | 会話間の記憶保持・ナレッジベース |

### 主要スキル
- `/brainstorming` - 機能設計前のブレインストーミング
- `/test-driven-development` - TDDワークフロー
- `/systematic-debugging` - 体系的デバッグ
- `/requesting-code-review` - コードレビュー依頼
- `/writing-plans` - 実装計画作成

---

## エージェント

| エージェント | 用途 |
|-------------|------|
| code-reviewer | コードレビュー、PR分析、変更影響分析 |
| test-engineer | テスト設計、カバレッジ分析、Flaky テスト診断 |
| frontend-engineer | フロントエンド設計・実装・パフォーマンス最適化 |
| spec-analyst | 仕様レビュー・品質向上・実装前の問題発見 |
| architecture-reviewer | アーキテクチャ評価・技術的負債の未然防止 |

---

## ステータスライン

カスタムスクリプト: `~/.claude/statusline.sh`

| 項目 | アイコン | 説明 |
|------|---------|------|
| 現在時刻 |  | 太字白で表示 |
| ディレクトリ |  | 作業ディレクトリ名 |
| Gitブランチ |  | 現在のブランチ |
| モデル名 | 󱌼 | Opus=紫、Sonnet=青、Haiku=緑 |
| コンテキスト使用率 | 󰠭 | プログレスバー + % |
| 行数変更 |  | +追加/-削除 |
| コスト | $ | セッション累計（USD） |
| セッションID | # | 先頭8文字 |

前提: Nerd Font、jq コマンド

---

## キーバインド

| キー | コマンド | 説明 |
|------|---------|------|
| Ctrl+L | clear | 画面クリア |
| Ctrl+O | open_in_editor | エディタで開く |
| Ctrl+R | retry | 最後のリクエストを再試行 |
| Ctrl+Shift+C | copy_last_response | 最後の応答をコピー |
| Ctrl+Shift+S | copy_last_command | 最後のコマンドをコピー |

---

## dotfiles 開発

### ディレクトリ構造
```
dotfiles/
├── bootstrap.sh           # セットアップスクリプト
├── Makefile               # GNU Stow操作
├── Brewfile               # Homebrewパッケージ
├── stow/                  # GNU Stowパッケージ
└── scripts/               # ユーティリティスクリプト
```

### 開発コマンド
```bash
make lint                  # ShellCheck実行
make check                 # ドライラン
make install               # 全パッケージインストール
```

### シェルスクリプト規約
1. ヘッダー: `#!/bin/bash` + `set -euo pipefail`
2. ローカル変数: `local` で宣言
3. ShellCheck準拠: 警告なしを目指す
