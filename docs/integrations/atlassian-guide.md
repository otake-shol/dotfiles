# Claude Code × Atlassian 連携ガイド

Claude CodeからJira/Confluenceを操作するための設定ガイドです。

---

## セットアップ

### 1. APIトークンの取得

1. [Atlassian APIトークン管理ページ](https://id.atlassian.com/manage-profile/security/api-tokens) にアクセス
2. 「APIトークンを作成」をクリック
3. ラベルを入力（例: `Claude Code MCP`）
4. 生成されたトークンをコピー

### 2. 環境変数の設定

`.zshrc` に以下を追加：

```bash
# MCP Atlassian settings
export JIRA_URL="https://your-domain.atlassian.net"
export JIRA_USERNAME="your-email@example.com"
export JIRA_API_TOKEN="your-api-token"
export CONFLUENCE_URL="https://your-domain.atlassian.net/wiki"
export CONFLUENCE_USERNAME="your-email@example.com"
export CONFLUENCE_API_TOKEN="your-api-token"
```

### 3. MCPサーバーの追加

```bash
claude mcp add atlassian \
  -e JIRA_URL='${JIRA_URL}' \
  -e JIRA_USERNAME='${JIRA_USERNAME}' \
  -e JIRA_API_TOKEN='${JIRA_API_TOKEN}' \
  -e CONFLUENCE_URL='${CONFLUENCE_URL}' \
  -e CONFLUENCE_USERNAME='${CONFLUENCE_USERNAME}' \
  -e CONFLUENCE_API_TOKEN='${CONFLUENCE_API_TOKEN}' \
  -s user -- uvx mcp-atlassian
```

### 4. 反映

```bash
source ~/.zshrc
# Claude Codeを再起動
```

---

## Jira操作

### 利用可能な操作

| 操作 | 説明 |
|------|------|
| チケット検索 | JQLで検索 |
| チケット取得 | 課題の詳細を取得 |
| チケット作成 | 新規課題を作成 |
| チケット更新 | 既存課題を更新 |
| ステータス変更 | ワークフロー遷移 |

### 使用例

```
# 検索
JIRAで優先度が高いチケットを検索して

# 詳細取得
PROJ-123の詳細を見せて

# 作成
PROJプロジェクトに「ログイン機能の修正」というチケットを作って

# ステータス変更
PROJ-123のステータスを「進行中」に変更して
```

### カスタムスキル

`/jira-create` - Jiraチケット作成用スキル

---

## Confluence操作

### 利用可能な操作

| 操作 | 説明 |
|------|------|
| ページ検索 | CQLで検索 |
| ページ取得 | ページ内容を取得 |
| ページ作成 | 新規ページを作成 |
| ページ更新 | 既存ページを更新 |

### 使用例

```
# 検索
Confluenceで「要件定義」に関するページを検索して

# 作成
Confluenceに新しいページを作成して
スペース: DEV
タイトル: 〇〇機能 要件定義書
```

### カスタムスキル

`/confluence-req` - 要件定義書作成・Confluence投稿用スキル

**モード:**
- 通常モード: 情報から要件定義書を作成・投稿
- セットアップモード: `--setup <URL>` で既存ページからテンプレート取得

---

## トラブルシューティング

### MCPサーバーが認識されない

```bash
# 一覧を確認
claude mcp list

# 再追加
claude mcp remove atlassian
claude mcp add atlassian ...
```

### 認証エラー

- `JIRA_URL` が正しいか確認（末尾スラッシュなし）
- `JIRA_USERNAME` がメールアドレスか確認
- `JIRA_API_TOKEN` が有効か確認

### 環境変数が読み込まれない

```bash
echo $JIRA_URL
# 空の場合
source ~/.zshrc
```

---

## 参考リンク

- [mcp-atlassian GitHub](https://github.com/sooperset/mcp-atlassian)
- [Atlassian APIトークン管理](https://id.atlassian.com/manage-profile/security/api-tokens)
- [JQL構文リファレンス](https://support.atlassian.com/jira-software-cloud/docs/use-advanced-search-with-jira-query-language-jql/)
