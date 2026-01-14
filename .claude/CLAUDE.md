# テストコード作成時の厳守事項

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

# Brewfile管理ルール

## 自動化の仕組み
- `brew install <package>` 実行後、Hooksにより自動でBrewfileが更新される
- スクリプト: `~/.claude/hooks/update-brewfile.sh`

## 手動更新時の手順
1. `brew install <package>` でツールをインストール
2. `~/dotfiles/Brewfile` を編集（ユーティリティセクション等に追加）
3. 必要に応じて `~/dotfiles/Brewfile.full` も更新

## Brewfileの構成
- `Brewfile` - 必須ツールのみ（新規Mac用）
- `Brewfile.full` - 全ツール（完全環境用）

---

# エディタ設定

## ファイルをエディタで開く場合
- **Antigravity**（Google製エディタ）を使用すること
- コマンド: `open -a "Antigravity" <ファイルパス>`
- 例: `open -a "Antigravity" ~/dotfiles/README.md`

---

# MCPサーバー設定

## 有効なMCPサーバー（13個）

### 認証不要（すぐ使える）
| サーバー | 用途 |
|---------|------|
| Context7 | リアルタイムドキュメント参照 |
| Serena | シンボリックコード解析（LSP統合） |
| Playwright | ブラウザ自動化・E2Eテスト |
| Puppeteer | 軽量ブラウザ自動化 |
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

## MCPサーバーガイド
詳細は `~/dotfiles/docs/mcp-servers-guide.md` を参照
