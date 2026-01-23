# ソフトウェア開発者向けMCPサーバーガイド

**作成日**: 2026-01-14
**対象**: Claude Codeを活用するソフトウェアエンジニア

---

## 現在の設定状況

| MCPサーバー | 状態 | 用途 |
|------------|------|------|
| Context7 | ✅ 設定済み | リアルタイムドキュメント参照 |
| Serena | ✅ 設定済み | シンボリックコード解析（LSP統合） |
| Playwright | ✅ 設定済み | ブラウザ自動化・E2Eテスト |
| Sequential Thinking | ✅ 設定済み | 構造化された問題解決 |
| GitHub | ⚠️ PAT必要 | Issue/PR操作・リポジトリ管理 |

---

## 🔴 優先度：高 - 必須級MCPサーバー

### 1. Playwright MCP Server

**ブラウザ自動化・E2Eテスト**

```json
{
  "playwright": {
    "command": "npx",
    "args": ["@playwright/mcp@latest"]
  }
}
```

| メリット | 詳細 |
|---------|------|
| 🎯 自然言語でブラウザ操作 | 「ログインページを開いてテスト」等の指示が可能 |
| 📸 スクリーンショット取得 | UI確認・バグ報告に活用 |
| 🧪 E2Eテスト自動生成 | テストコードを会話内で生成 |
| 🔍 アクセシビリティツリー解析 | スクリーンショットより効率的 |
| 📝 フォーム自動入力 | データ入力テストの自動化 |

| デメリット | 詳細 |
|-----------|------|
| ⚠️ リソース消費 | ブラウザ起動によるメモリ使用 |
| ⏱️ 初回セットアップ | Chromium等のダウンロードが必要 |
| 🔒 セキュリティ考慮 | 認証情報の取り扱いに注意 |

---

### 2. GitHub MCP Server

**Issue/PR/リポジトリ管理**

```json
{
  "github": {
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp/",
    "headers": {
      "Authorization": "Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}"
    }
  }
}
```

**事前準備**: GitHub Personal Access Token (PAT) の取得が必要
- Settings → Developer settings → Personal access tokens → Fine-grained tokens
- 必要なスコープ: `repo`, `issues`, `pull_requests`

| メリット | 詳細 |
|---------|------|
| 📋 Issue操作 | 作成・更新・クローズを会話内で完結 |
| 🔀 PR管理 | 作成・レビューコメント・マージ |
| 🔍 コード検索 | リポジトリ内のコード検索 |
| 📊 CI/CD監視 | ワークフロー状態の確認 |
| 👥 コラボレーション | レビュアーアサイン等 |

| デメリット | 詳細 |
|-----------|------|
| 🔑 トークン管理 | PAT の安全な保管が必要 |
| ⚠️ 権限設定 | 過剰な権限付与に注意 |
| 💰 API制限 | レートリミットに注意 |

---

### 3. Sequential Thinking MCP

**構造化された問題解決**

```json
{
  "sequential-thinking": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
  }
}
```

| メリット | 詳細 |
|---------|------|
| 🧠 段階的思考 | 複雑な問題を段階的に分解 |
| 🔄 反復的改善 | アプローチの見直しが可能 |
| 🏗️ 設計支援 | アーキテクチャ決定の補助 |
| 🐛 デバッグ強化 | 体系的なデバッグアプローチ |

| デメリット | 詳細 |
|-----------|------|
| ⏱️ 応答時間増加 | 思考プロセスに時間がかかる |
| 📊 トークン消費 | 詳細な分析でトークン増加 |

---

## 🟡 優先度：中 - 用途に応じて推奨

### 4. Linear MCP Server

**モダンなIssue/プロジェクト管理**

```json
{
  "linear": {
    "type": "http",
    "url": "https://mcp.linear.app/mcp"
  }
}
```

| メリット | デメリット |
|---------|-----------|
| Issueの作成・更新・検索 | Linearを使用していない場合は不要 |
| サイクル/プロジェクト管理 | OAuth認証のセットアップが必要 |
| チーム間の連携 | |

---

### 5. Supabase MCP Server

**BaaS (Backend as a Service) 統合**

```json
{
  "supabase": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp"
  }
}
```

| メリット | デメリット |
|---------|-----------|
| データベース操作（CRUD） | Supabaseプロジェクトが必要 |
| 認証ユーザー管理 | 本番DBへの誤操作リスク |
| ストレージ操作 | |
| Edge Functions管理 | |

---

### 6. Firebase MCP Server

**Google Firebase統合**

```json
{
  "firebase": {
    "command": "npx",
    "args": ["-y", "firebase-tools@latest", "mcp"]
  }
}
```

| メリット | デメリット |
|---------|-----------|
| Firestore操作 | Firebaseプロジェクトが必要 |
| Cloud Functions管理 | 認証設定が複雑 |
| Hosting操作 | |
| Analytics確認 | |

---

### 7. Brave Search MCP

**プライバシー重視のWeb検索**

```json
{
  "brave-search": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-server-brave-search"],
    "env": {
      "BRAVE_API_KEY": "${BRAVE_API_KEY}"
    }
  }
}
```

| メリット | デメリット |
|---------|-----------|
| リアルタイムWeb検索 | Brave API Keyが必要（無料枠あり） |
| プライバシー保護 | Claude内蔵検索と重複する場合も |
| 技術情報の取得 | |

---

### 8. Puppeteer MCP

**軽量ブラウザ自動化**

```json
{
  "puppeteer": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-server-puppeteer"]
  }
}
```

| メリット | デメリット |
|---------|-----------|
| Playwrightより軽量 | Playwrightより機能が限定的 |
| スクレイピング向け | クロスブラウザ非対応 |
| 高速起動 | |

---

## 🟢 優先度：低 - 特定用途向け

### 9. Sentry MCP

**エラー監視・パフォーマンス分析**

```json
{
  "sentry": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-server-sentry"],
    "env": {
      "SENTRY_AUTH_TOKEN": "${SENTRY_AUTH_TOKEN}"
    }
  }
}
```

| 用途 | メリット |
|------|---------|
| エラー追跡 | エラーの詳細分析・修正提案 |
| パフォーマンス監視 | ボトルネック特定 |
| リリース管理 | デプロイ影響の確認 |

---

### 10. PostHog MCP

**プロダクトアナリティクス**

| 用途 | メリット |
|------|---------|
| ユーザー行動分析 | 機能改善の意思決定支援 |
| A/Bテスト管理 | 実験結果の分析 |
| フィーチャーフラグ | 段階的リリースの管理 |

---

### 11. Notion MCP

**ドキュメント・ナレッジベース管理**

| 用途 | メリット |
|------|---------|
| ドキュメント検索 | 技術ドキュメントへのアクセス |
| ページ作成・更新 | 設計ドキュメントの自動生成 |
| データベース操作 | プロジェクト情報の管理 |

---

### 12. Figma MCP

**デザイン→コード変換**

| 用途 | メリット |
|------|---------|
| デザイン読み取り | Figmaフレームの解析 |
| コード生成 | デザインからのUI実装 |
| スタイル抽出 | カラー・フォント情報取得 |

---

### 13. Slack MCP

**チームコミュニケーション**

| 用途 | メリット |
|------|---------|
| メッセージ送信 | 通知・レポート自動化 |
| チャンネル検索 | 過去の議論参照 |
| ファイル共有 | 成果物の共有 |

---

### 14. Apidog MCP

**API仕様からのコード生成**

```json
{
  "apidog": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-server-apidog"],
    "env": {
      "APIDOG_API_KEY": "${APIDOG_API_KEY}"
    }
  }
}
```

| 用途 | メリット |
|------|---------|
| 型安全なクライアント生成 | OpenAPI仕様からの自動生成 |
| モックサーバー作成 | フロントエンド開発の並行化 |
| API検証 | レスポンス整合性チェック |

---

### 15. Docker MCP Toolkit

**200以上のコンテナ化されたMCPサーバー**

```bash
# Docker Desktopからワンクリックで追加可能
```

| 用途 | メリット |
|------|---------|
| 依存関係の分離 | ローカル環境を汚さない |
| 一括管理 | 複数MCPの統合管理 |
| クロスプラットフォーム | Mac/Windows/Linux対応 |

---

## クラウドインフラ系 MCP

### AWS MCP
- Lambda, DynamoDB, S3, Step Functions操作
- インフラ構築・管理の自動化

### Cloudflare MCP
- Workers, R2, KV操作
- エッジコンピューティング管理

### GCP MCP (コミュニティ)
- BigQuery, Compute Engine, Cloud Functions
- Google Cloud統合

---

## 推奨構成

### 最小構成（開発効率重視）
```
Context7 + Serena + GitHub + Playwright
```

### 標準構成（フルスタック開発）
```
Context7 + Serena + GitHub + Playwright + Sequential Thinking + Supabase/Firebase
```

### 大規模プロジェクト向け
```
上記 + Linear/Notion + Sentry + Slack
```

---

## ベストプラクティス

1. **段階的に追加**: 2-3個から始めて徐々に拡張
2. **起動時間を意識**: 多すぎるMCPはClaude Code起動を遅延させる
3. **セキュリティ第一**: トークンは環境変数で管理
4. **用途に合わせて選択**: 使わないMCPは無効化

---

## 参考リンク

- [The 10 Must-Have MCP Servers for Claude Code (2025)](https://roobia.medium.com/the-10-must-have-mcp-servers-for-claude-code-2025-developer-edition-43dc3c15c887)
- [Best MCP Servers for Claude Code - MCPcat](https://mcpcat.io/guides/best-mcp-servers-for-claude-code/)
- [6 Must-Have MCP Servers for Web Developers in 2025](https://www.deployhq.com/blog/6-must-have-mcp-servers-for-web-developers-in-2025)
- [Awesome MCP Servers (GitHub)](https://github.com/punkpeye/awesome-mcp-servers)
- [Docker MCP Toolkit](https://www.docker.com/blog/add-mcp-servers-to-claude-code-with-mcp-toolkit/)
