# 環境・技術設定

CLAUDE.md から分離した技術スタック、ツール設定、開発環境の詳細。

---

## 技術スタック

### メイン技術
- React / Next.js
- TypeScript（厳格モード推奨）
- Node.js 20.x（.tool-versionsで管理）
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

| Hook | イベント | 用途 |
|------|---------|------|
| update-brewfile.sh | (手動) | Brewfile自動更新 |
| auto-format.sh | PostToolUse | ファイル編集後に自動フォーマット |
| notify.sh | Notification | macOS通知でタスク完了を通知 |

### auto-format.sh の対応形式
- **Prettier**: js, jsx, ts, tsx, json, md, css, scss, html, yaml, yml
- **shfmt**: sh, bash

---

## パーミッション設定

### 自動許可（allow）
- `npm run *`, `yarn *`, `pnpm *`
- `npx prettier *`, `npx eslint *`
- `git status/diff/log/branch/add/commit/stash`
- `make *`, `brew *`

### 自動拒否（deny）
- `.env*`, `credentials*`, `*secret*` の読み取り
- `rm -rf /`, `rm -rf ~`
- `curl * | sh/bash`

### 確認が必要（ask）
- `git push *`
- `git reset --hard*`
- `git checkout .`
- `git clean *`

---

## エディタ設定

ファイルをエディタで開く場合:
- **Antigravity**（Google製エディタ）を使用
- コマンド: `open -a "Antigravity" <ファイルパス>`

---

## MCPサーバー

| サーバー | 用途 | 認証 |
|---------|------|------|
| Context7 | リアルタイムドキュメント参照 | 不要 |
| Serena | シンボリックコード解析（LSP統合） | 不要 |
| Playwright | ブラウザ自動化・E2Eテスト | 不要 |
| Atlassian | Jira/Confluence操作 | 不要 |
| Figma | デザイン→コード変換 | OAuth |

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

### 主要スキル
- `/brainstorming` - 機能設計前のブレインストーミング
- `/test-driven-development` - TDDワークフロー
- `/systematic-debugging` - 体系的デバッグ
- `/requesting-code-review` - コードレビュー依頼
- `/writing-plans` - 実装計画作成

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
