## コミュニケーションの好み

## 質問の仕方
- 複数質問がある場合は、まず全体像（質問リスト）を共有する
- その後、一問一答形式で1つずつ回答を得る
- 一度に複数の質問を投げない

## 説明の仕方
- 結論ファーストで伝える
- 詳細は必要に応じて追記
- 選択肢がある場合はおすすめを提示しつつ、トレードオフも説明する

---

## 技術スタック・開発環境

## メイン技術
- React / Next.js
- TypeScript（厳格モード推奨）
- Node.js 20.x（.tool-versionsで管理）

## パッケージマネージャー
- npm / yarn / pnpm いずれも可
- プロジェクトのlock fileに従う

## 開発スタイル
- 個人開発・チーム開発の両方

## Gitフロー
- 基本は **git-flow** に従う（feature/develop/release/hotfix/master）
- 個人開発で工数削減したい場合は、masterブランチへの直接プッシュもOK

## 作業の進め方
- **新機能追加**: まず設計/計画を提示してから実装に着手する
- **バグ修正**: 原因調査結果を報告してから修正に着手する
- **リファクタリング**: 変更方針と影響範囲を提示し、段階的に確認しながら進める

## 実装依頼時の必須フロー（重要）

**いきなりコードを書かないこと。必ず以下のフローに従う。**

### Step 1: 対応案の提示
実装依頼を受けたら、まず複数の対応案（2〜4案）を提示する。

### Step 2: 各案の比較
各案について以下を明記する：
- **概要**: 何をどうするか
- **メリット**: この案の利点
- **デメリット**: この案の欠点・リスク
- **工数感**: 軽い / 中程度 / 重い

### Step 3: おすすめの提示
Claudeとしてのおすすめ案を明示し、その理由を説明する。

### Step 4: 人間の承認を待つ
「どの案で進めますか？」と確認し、**人間が方向性を決定してから**実装に着手する。

### 提案フォーマット例
```
## 対応案

### 案1: ○○○（おすすめ）
- 概要: ...
- メリット: ...
- デメリット: ...
- 工数: 軽い

### 案2: △△△
- 概要: ...
- メリット: ...
- デメリット: ...
- 工数: 中程度

---
**おすすめ**: 案1
理由: ...

どの案で進めますか？
```

### 例外（提案スキップ可能なケース）
- 明らかに1つしか方法がない場合
- ユーザーが具体的な実装方法を指定済みの場合
- typo修正など軽微な変更

## コードスタイル
- 命名規則・TypeScriptの型定義: プロジェクトの既存ルールに従う
- コメント: 関数やコンポーネントにはJSDocを書く
- ディレクトリ構成: レイヤーベース（components, hooks, utils など）を好む

## コミットメッセージ規約
- **Conventional Commits** に従う
- フォーマット: `<type>: <subject>`
- Type: feat, fix, docs, style, refactor, perf, test, chore, ci
- 詳細は `~/dotfiles/stow/git/commit-template.txt` を参照

---

## テストコード作成時の厳守事項

## テストフレームワーク
- **Vitest**（推奨）または **Jest**
- React コンポーネント: **React Testing Library**
- E2E: **Playwright**

## 絶対に守ってください

### テストコードの品質
- テストは必ず実際の機能を検証すること
- 'expect(true).toBe(true)'のような意味のないアサーションは絶対に描かない
- 各テストケースは具体的な入力と期待される出力を検証すること
- モックは必要最小限に留め、実際の動作に近い形でテストすること

### ハードコーディングの禁止
- テストを通すためだけのハードコードは絶対に禁止
- 本番コード'if(testMode)'のような条件分岐を入れない
- テスト用の特別な値（マジックナンバー）を本番コードに埋め込まない
- 環境変数や設定ファイルを使用して、テスト環境と本番環境を適切に分離すること

### テスト実装の原則
- テストが失敗する状態から始めること（Red-Green-Refactor)
- 境界値、異常系、エラーケースも必ずテストすること
- カバレッジだけでなく、実際の品質を重視すること
- テストケース名は何をテストしているか明確に記述すること

### 実装前の確認
- 機能の使用を正しく理解してからテストを書くこと
- 不明な点があれば、仮の実装ではなく、ユーザーに確認すること

---

## Brewfile管理ルール

## 自動化の仕組み
- `brew install <package>` 実行後、Hooksにより自動でBrewfileが更新される
- スクリプト: `~/.claude/hooks/update-brewfile.sh`

## 手動更新時の手順
1. `brew install <package>` でツールをインストール
2. `~/dotfiles/Brewfile` を編集（ユーティリティセクション等に追加）

---

## エディタ設定

## ファイルをエディタで開く場合
- **Antigravity**（Google製エディタ）を使用すること
- コマンド: `open -a "Antigravity" <ファイルパス>`
- 例: `open -a "Antigravity" ~/dotfiles/README.md`

---

## MCPサーバー設定

## 有効なMCPサーバー（12個）

### 認証不要（すぐ使える）
| サーバー | 用途 |
|---------|------|
| Context7 | リアルタイムドキュメント参照 |
| Serena | シンボリックコード解析（LSP統合） |
| Playwright | ブラウザ自動化・E2Eテスト |
| Sequential Thinking | 構造化された問題解決 |

### OAuth認証が必要（初回接続時に認証）
| サーバー | 用途 |
|---------|------|
| Linear | Issue/プロジェクト管理 |
| Supabase | BaaS（DB/認証/ストレージ） |
| Notion | ドキュメント/ナレッジベース |
| Figma | デザイン→コード変換 |
| Slack | チームコミュニケーション |

### 環境変数が必要
| サーバー | 必要な環境変数 | 取得方法 |
|---------|---------------|---------|
| GitHub | `GITHUB_PERSONAL_ACCESS_TOKEN` | Settings → Developer settings → PAT |
| Brave Search | `BRAVE_API_KEY` | https://brave.com/search/api/ |
| Sentry | `SENTRY_AUTH_TOKEN` | Settings → Auth Tokens |

## 環境変数の設定（.zshrcに追加）
```bash
# MCP認証用（必要に応じて設定）
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxxxx"
export BRAVE_API_KEY="BSAxxxxx"
export SENTRY_AUTH_TOKEN="sntrys_xxxxx"
```

---

## プラグイン設定

### インストール済みプラグイン

| プラグイン | マーケットプレイス | 用途 |
|-----------|-------------------|------|
| superpowers | obra/superpowers-marketplace | 開発ワークフロー強化（TDD、コードレビュー、デバッグ等） |

### 新規マシンでのセットアップ

```bash
# 1. マーケットプレイスを追加
claude /plugin marketplace add obra/superpowers-marketplace

# 2. プラグインをインストール
claude /plugin install superpowers@superpowers-marketplace
```

### superpowersプラグインの主要スキル

- `/brainstorming` - 機能設計前のブレインストーミング
- `/test-driven-development` - TDDワークフロー
- `/systematic-debugging` - 体系的デバッグ
- `/requesting-code-review` - コードレビュー依頼
- `/writing-plans` - 実装計画作成

---

## dotfiles 開発ガイドライン

## ディレクトリ構造

```
dotfiles/
├── bootstrap.sh           # セットアップスクリプト
├── Makefile               # GNU Stow操作
├── Brewfile               # Homebrewパッケージ
├── stow/                  # GNU Stowパッケージ
│   ├── zsh/               # .zshrc, .aliases, .zsh/
│   ├── git/               # .gitconfig
│   ├── claude/            # .claude/ (このファイル)
│   ├── nvim/              # .config/nvim/
│   ├── ghostty/           # .config/ghostty/
│   ├── bat/               # .config/bat/
│   └── atuin/             # .config/atuin/
├── scripts/               # ユーティリティスクリプト
│   ├── setup/             # OS別セットアップ
│   ├── maintenance/       # verify-setup.sh 等
│   ├── utils/             # ヘルパースクリプト
│   └── lib/               # 共通ライブラリ
└── docs/                  # ドキュメント
```

## 開発コマンド

```bash
# Lint
make lint                  # ShellCheck実行

# Stow操作
make check                 # ドライラン
make install               # 全パッケージインストール
make install-zsh           # 個別パッケージ

# ベンチマーク
bash scripts/utils/zsh_benchmark.sh
```

## シェルスクリプト規約

1. **ヘッダー**: `#!/bin/bash` + `set -euo pipefail`
2. **ローカル変数**: `local` で宣言
3. **カラー出力**: 共通の色定義を使用
4. **エラーハンドリング**: trap で cleanup
5. **ShellCheck準拠**: 警告なしを目指す

## CI/CD

- **lint.yml**: ShellCheck, YAML Lint, Markdown Lint, セキュリティスキャン
- **統合テスト**: 意図的に追加しない（ローカルでの `bootstrap.sh --dry-run` で十分）

## 貢献ガイドライン

1. ShellCheckを通す
2. Conventional Commitsに従う
3. PRの説明を丁寧に書く
