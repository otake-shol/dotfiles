# Antigravity IDE 拡張機能ガイド

## 前提：マーケットプレイス設定

デフォルトのOpen VSXは拡張機能が少ないため、**VS Code Marketplaceへの切り替え**を推奨：

```
Settings → Editor → Marketplace URLs を変更:
- Item URL: https://marketplace.visualstudio.com/items
- Gallery URL: https://marketplace.visualstudio.com/_apis/public/gallery
```

---

## カテゴリ別おすすめ拡張機能

### 1. 言語サポート

| 拡張機能 | 言語 | 備考 |
|----------|------|------|
| **ESLint** | JavaScript/TypeScript | 必須 |
| **Prettier** | 全般 | コードフォーマッター |
| **TypeScript Vue Plugin (Volar)** | Vue | Vue 3対応 |
| **ES7+ React Snippets** | React | スニペット集 |
| **Python** (ms-python) | Python | 公式拡張 |
| **Ruff** | Python | 高速リンター |
| **Go** | Go | 公式拡張 |
| **rust-analyzer** | Rust | 必須 |
| **PHP Intelephense** | PHP | 高機能補完 |
| **YAML** | YAML | スキーマ対応 |
| **Even Better TOML** | TOML | 設定ファイル用 |

> ⚠️ **注意**: C# Dev Kit、Pylanceは**Microsoft専用**のため非対応
>
> **代替案:**
> - C# → `muhammad-sammy.csharp`（非公式）
> - Python → `Ruff` + 標準Python拡張

---

### 2. AI/エージェント機能

| 拡張機能 | 説明 |
|----------|------|
| **AMP** | AIアシスタント（.vsix手動インストール）|
| **Continue** | オープンソースAIコーディング |
| **Codeium** | 無料AI補完 |
| **Tabnine** | AIコード補完 |
| **Toolkit for Antigravity** | クォータ追跡等（OpenVSX） |

---

### 3. Git/バージョン管理

| 拡張機能 | 説明 |
|----------|------|
| **GitLens** | Git履歴・blame表示 |
| **Git Graph** | ブランチ可視化 |
| **GitHub Pull Requests** | PRレビュー |
| **GitHub Copilot** | AIペアプログラミング |
| **Conventional Commits** | コミットメッセージ規約 |

---

### 4. コード品質

| 拡張機能 | 説明 |
|----------|------|
| **ESLint** | JavaScript/TS リンター |
| **Prettier** | コードフォーマッター |
| **SonarLint** | セキュリティ・品質チェック |
| **Error Lens** | インラインエラー表示 |
| **Code Spell Checker** | スペルチェック |
| **Import Cost** | インポートサイズ表示 |
| **Better Comments** | コメント色分け |

---

### 5. UI/UX・テーマ

| 拡張機能 | 説明 |
|----------|------|
| **GitHub Theme** | GitHub風テーマ |
| **One Dark Pro** | 人気ダークテーマ |
| **Tokyo Night** | モダンテーマ |
| **Catppuccin** | パステルテーマ |
| **Material Icon Theme** | ファイルアイコン |
| **vscode-icons** | アイコンセット |
| **Bracket Pair Colorizer 2** | 括弧色分け（内蔵代替あり） |
| **indent-rainbow** | インデント可視化 |

---

### 6. 生産性向上

| 拡張機能 | 説明 |
|----------|------|
| **Path Intellisense** | ファイルパス補完 |
| **Auto Rename Tag** | HTML/JSXタグ自動リネーム |
| **Auto Close Tag** | タグ自動閉じ |
| **Multiple Cursor Case Preserve** | マルチカーソル改善 |
| **Todo Tree** | TODO/FIXME一覧 |
| **Bookmarks** | コードブックマーク |
| **Project Manager** | プロジェクト切替 |
| **REST Client** | HTTPリクエストテスト |
| **Thunder Client** | APIテスト（軽量Postman） |

---

### 7. フレームワーク特化

| 拡張機能 | フレームワーク |
|----------|---------------|
| **Tailwind CSS IntelliSense** | Tailwind |
| **PostCSS Language Support** | PostCSS |
| **Prisma** | Prisma ORM |
| **GraphQL** | GraphQL |
| **Docker** | Docker |
| **Kubernetes** | K8s |
| **Terraform** | IaC |
| **AWS Toolkit** | AWS |

---

### 8. MCP統合（Antigravity特化）

Antigravityの強みである**MCPサーバー連携**：

| MCP Server | 用途 |
|------------|------|
| **Playwright** | ブラウザ自動化・E2Eテスト |
| **Supabase** | DBクエリ・管理 |
| **PostgreSQL** | DB直接操作 |
| **GitHub** | Issue/PR操作 |
| **Docker** | コンテナ管理 |
| **Figma** | デザイン連携 |
| **Stripe** | 決済処理 |
| **n8n** | ワークフロー自動化 |
| **Vercel** | デプロイ・ログ |
| **Linear** | タスク管理 |

---

## 推奨インストールセット

### 最小構成（必須）

```
ESLint, Prettier, GitLens, Error Lens,
Material Icon Theme, Path Intellisense
```

### フロントエンド開発

```
+ Tailwind CSS IntelliSense, ES7+ React Snippets,
  Auto Rename Tag, REST Client
```

### バックエンド開発

```
+ Docker, Prisma, Thunder Client,
  YAML, Database Client
```

### フルスタック

```
上記すべて + GitHub Copilot, Todo Tree,
Project Manager
```

---

## インストール方法

### 1. マーケットプレイス経由（推奨）

```
Cmd+Shift+X → 検索 → Install
```

### 2. VSIX手動インストール

```bash
# VS Code Marketplaceからダウンロード後
antigravity --install-extension /path/to/extension.vsix
```

---

## 参考リンク

- [Google Antigravity 公式](https://antigravity.google/)
- [VS Code Marketplace拡張機能のインストール方法](https://medium.com/@agurindapalli/how-to-install-vs-code-marketplace-extensions-in-googles-antigravity-ide-example-deepblue-theme-689cdcd735eb)
- [AntigravityをVS Codeスタイルにする](https://jimmysong.io/blog/antigravity-vscode-style-ide/)
- [Antigravity Codes - MCP/AIルール集](https://antigravity.codes)
- [VS Codeからの移行ガイド](https://www.appsoftware.com/blog/setting-up-google-antigravity-coming-from-vscode)
