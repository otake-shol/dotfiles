# Claude Code × Jira 連携ガイド

Claude CodeからJiraタスクの起票・検索・更新を行う方法です。

---

## 前提条件

- Claude Code インストール済み
- Jira Cloud アカウント
- Atlassian APIトークン発行済み

---

## セットアップ

### 1. uv（uvx）のインストール

```bash
brew install uv
```

### 2. MCP Atlassian サーバーの追加

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

### 3. 環境変数の設定

`.zshrc` に以下を追加：

```bash
# MCP Atlassian settings (Jira/Confluence)
export JIRA_URL="https://your-domain.atlassian.net"
export JIRA_USERNAME="your-email@example.com"
export JIRA_API_TOKEN="your-api-token"
export CONFLUENCE_URL="https://your-domain.atlassian.net/wiki"
export CONFLUENCE_USERNAME="your-email@example.com"
export CONFLUENCE_API_TOKEN="your-api-token"
```

### 4. APIトークンの発行方法

1. https://id.atlassian.com/manage-profile/security/api-tokens にアクセス
2. 「APIトークンを作成」をクリック
3. ラベルを入力（例：`Claude Code MCP`）
4. 「作成」をクリック
5. トークンをコピーして `.zshrc` に設定

### 5. 反映

```bash
source ~/.zshrc
# Claude Codeを再起動
```

---

## 利用可能なJira操作

| 操作 | 説明 |
|------|------|
| チケット検索 | JQLで検索 |
| チケット取得 | 課題の詳細を取得 |
| チケット作成 | 新規課題を作成 |
| チケット更新 | 既存課題を更新 |
| ステータス変更 | ワークフロー遷移 |

---

## 使用例

### チケットの検索

```
JIRAで優先度が高いチケットを検索して
```

```
プロジェクトPROJで未完了のタスクを一覧表示して
```

### チケットの詳細取得

```
PROJ-123の詳細を見せて
```

### チケットの作成

```
JIRAにチケットを作成して
プロジェクト: PROJ
タイトル: ログイン機能の修正
説明: パスワードリセットが動作しない問題を修正する
優先度: 高
```

または自然言語で：

```
PROJプロジェクトに「ログイン機能の修正」というチケットを作って。
パスワードリセットが動かない問題で、優先度は高めで。
```

### チケットの更新

```
PROJ-123の説明を更新して。
「調査の結果、メール送信サービスの設定が原因と判明」を追記して。
```

### ステータスの変更

```
PROJ-123のステータスを「進行中」に変更して
```

---

## Confluence連携

同じMCPサーバーでConfluence操作も可能です。

### ページの検索

```
Confluenceで「要件定義」に関するページを検索して
```

### ページの作成

```
Confluenceに新しいページを作成して
スペース: DEV
タイトル: 〇〇機能 要件定義書
内容: ...
```

---

## トラブルシューティング

### MCPサーバーが認識されない

```bash
# MCPサーバー一覧を確認
claude mcp list

# atlassianが表示されない場合は再追加
claude mcp remove atlassian
claude mcp add atlassian ...
```

### 認証エラー

- `JIRA_URL` が正しいか確認（末尾にスラッシュなし）
- `JIRA_USERNAME` がメールアドレスか確認
- `JIRA_API_TOKEN` が有効か確認（期限切れの場合は再発行）

### 環境変数が読み込まれない

```bash
# 環境変数を確認
echo $JIRA_URL
echo $JIRA_API_TOKEN

# 空の場合は .zshrc を再読み込み
source ~/.zshrc
```

---

## 参考リンク

- [mcp-atlassian GitHub](https://github.com/sooperset/mcp-atlassian)
- [Atlassian APIトークン管理](https://id.atlassian.com/manage-profile/security/api-tokens)
- [Jira Cloud REST API](https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/)
- [JQL構文リファレンス](https://support.atlassian.com/jira-software-cloud/docs/use-advanced-search-with-jira-query-language-jql/)
