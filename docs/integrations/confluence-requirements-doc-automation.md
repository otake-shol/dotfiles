# Confluence 要件定義書 自動化ガイド

Claude Codeを使ってConfluenceへの要件定義書作成を自動化するためのガイド。

## 概要

### 背景・課題

- 要件定義書の情報源が多岐にわたる（Slack、会議録、既存ドキュメント、口頭メモなど）
- Confluenceへの転記作業が手間
- フォーマットはConfluenceテンプレートで管理済み

### 解決策

Claude Code + mcp-atlassian を使い、以下のワークフローを実現する：

```
[情報収集] → [Claude Codeで整形] → [mcp-atlassian経由でConfluenceに自動投稿]
```

## 使用するMCPサーバー

### sooperset/mcp-atlassian

- **GitHub**: https://github.com/sooperset/mcp-atlassian
- **対応製品**: Jira, Confluence
- **対応環境**: Cloud / Server / Data Center
- **認証方式**: APIトークン
- **主な機能**:
  - Confluenceページの検索・取得・作成・更新
  - Jira課題の検索・取得・作成・更新
  - 自然言語でのCQL/JQLクエリ実行

### 他の選択肢（参考）

| サーバー | 特徴 |
|---------|------|
| [Atlassian公式](https://github.com/atlassian/atlassian-mcp-server) | OAuth認証、セットアップが簡単、Cloud専用 |
| [aashari/confluence](https://github.com/aashari/mcp-server-atlassian-confluence) | Confluence特化、トークン効率最適化 |

## セットアップ手順

### 1. APIトークンの取得

1. [Atlassian APIトークン管理ページ](https://id.atlassian.com/manage-profile/security/api-tokens) にアクセス
2. 「APIトークンを作成」をクリック
3. ラベルを入力（例: `mcp-atlassian`）
4. 生成されたトークンをコピー

### 2. Claude CodeにMCPサーバーを追加

以下のコマンドを実行（値は自分の環境に置き換え）：

```bash
claude mcp add atlassian \
  -e CONFLUENCE_URL=https://your-company.atlassian.net/wiki \
  -e CONFLUENCE_USERNAME=your.email@example.com \
  -e CONFLUENCE_API_TOKEN=your_api_token \
  -- uvx mcp-atlassian
```

### 3. 動作確認

Claude Codeを再起動し、MCPサーバーが認識されているか確認：

```bash
claude mcp list
```

## 使い方

### カスタムスキル `/confluence-req`

要件定義書作成用のカスタムスキルを用意しています。

**ファイル**: `~/.claude/commands/confluence-req.md`

### モード

このスキルは2つのモードで動作します：

| モード | 用途 | コマンド |
|--------|------|----------|
| 通常モード | 情報から要件定義書を作成・投稿 | `/confluence-req` |
| セットアップモード | 既存ページからテンプレートを取得 | `/confluence-req --setup <URL>` |

### 基本的な使い方（通常モード）

```
/confluence-req

<ここに情報を貼り付け>
- Slackのやり取り
- 会議メモ
- ヒアリング内容
- 既存ドキュメントの内容
```

### テンプレート取得（セットアップモード）

既存のConfluenceページからテンプレートを取得：

```
/confluence-req --setup https://xxx.atlassian.net/wiki/spaces/DEV/pages/123456789
```

または

```
/confluence-req --setup 123456789
```

取得後、以下の選択肢から保存方法を選べます：
- **A. スキルに埋め込む** → スキルファイルを直接更新
- **B. 外部ファイルに保存** → `~/.claude/templates/confluence-req-template.xml`
- **C. template_page_idとして設定** → 毎回ページから取得（常に最新）

### プロジェクト別テンプレート

複数プロジェクトで異なるテンプレートを使う場合：

```
~/.claude/templates/
├── confluence-req-template.xml           # デフォルト
├── confluence-req-template-projectA.xml  # プロジェクトA用
└── confluence-req-template-projectB.xml  # プロジェクトB用
```

使用時：
```
/confluence-req --template projectA
```

### デフォルト設定

`~/.claude/commands/confluence-req.md` 内のデフォルト設定セクションを編集：

```yaml
confluence:
  space_key: "DEV"           # スペースキー
  parent_id: "123456789"     # 親ページID
  title_prefix: "[要件定義] " # タイトルの接頭辞
  template_page_id: ""       # テンプレートページID（常に最新を取得）
```

- **設定済み**: 投稿時にデフォルト値を使用
- **空欄**: 投稿時に毎回確認

### テンプレート解決の優先順位

1. `--template` オプションで指定
2. `template_page_id` が設定されている場合 → Confluenceから取得
3. 外部ファイル（`~/.claude/templates/confluence-req-template.xml`）
4. スキルに埋め込まれたデフォルトテンプレート

#### 親ページIDの調べ方

ConfluenceページのURLから取得：

```
https://xxx.atlassian.net/wiki/spaces/DEV/pages/123456789/PageTitle
                                              ↑
                                          この数字がparent_id / template_page_id
```

### 処理フロー

1. 入力情報を分析し、テンプレートフォーマットに整理
2. 不明点・曖昧な点があれば確認を求める
3. 要件定義書の内容を確認（Markdown形式で表示）
4. 確認後、Storage Format（XML）に変換
5. Confluenceに投稿（デフォルト設定 or 都度確認）
6. 投稿成功時、ページURLを表示

### テンプレート構造

```
1. 概要（infoボックス）
2. 背景・目的（expand）
3. 機能要件（expand）
4. 非機能要件（expand）
5. 画面仕様（expand）
6. スケジュール（expand）
```

### 使用するConfluenceマクロ

| マクロ | 用途 | 使用箇所 |
|--------|------|----------|
| `toc` | 目次の自動生成 | ページ先頭 |
| `expand` | セクションの折りたたみ | 各セクション |
| `info` | 重要情報の強調（青枠） | 概要、注意事項など |

※ マクロはStorage Format（XML）で出力されるため、Confluenceで正しくレンダリングされます

### カスタマイズ

`~/.claude/commands/confluence-req.md` を編集して以下を変更可能：
- テンプレート構造（セクションの追加・削除・変更）
- 使用するマクロの追加・変更
- デフォルトの投稿先
- タイトルの命名規則

#### 追加可能なマクロ例

```xml
<!-- 警告ボックス -->
<ac:structured-macro ac:name="warning">
  <ac:rich-text-body><p>警告内容</p></ac:rich-text-body>
</ac:structured-macro>

<!-- メモボックス -->
<ac:structured-macro ac:name="note">
  <ac:rich-text-body><p>メモ内容</p></ac:rich-text-body>
</ac:structured-macro>

<!-- ステータスラベル -->
<ac:structured-macro ac:name="status">
  <ac:parameter ac:name="title">進行中</ac:parameter>
  <ac:parameter ac:name="colour">Yellow</ac:parameter>
</ac:structured-macro>
```

## 参考リンク

- [sooperset/mcp-atlassian GitHub](https://github.com/sooperset/mcp-atlassian)
- [Atlassian APIトークン管理](https://id.atlassian.com/manage-profile/security/api-tokens)
- [Atlassian公式MCPサーバー](https://github.com/atlassian/atlassian-mcp-server)
- [Atlassian公式ブログ - Remote MCP Server発表](https://www.atlassian.com/blog/announcements/remote-mcp-server)
