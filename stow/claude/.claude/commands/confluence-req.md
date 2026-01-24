# /confluence-req - 要件定義書作成・Confluence投稿

入力された情報から要件定義書を作成し、Confluenceに投稿します。

## モード

このスキルは2つのモードで動作します：

### 1. 通常モード（デフォルト）
情報を入力 → テンプレートに沿って整形 → Confluenceに投稿

### 2. テンプレート取得モード
既存のConfluenceページからテンプレートを取得して設定

```
/confluence-req --setup <ページURL or ページID>
```

## デフォルト設定

```yaml
# 投稿先の設定（必要に応じて編集）
confluence:
  space_key: ""           # 例: "DEV", "PROJ"
  parent_id: ""           # 例: "123456789"（親ページのID）
  title_prefix: ""        # 例: "[要件定義] "
  template_page_id: ""    # 例: "987654321"（テンプレートページのID）
```

※ 空欄の場合は投稿時に確認します
※ template_page_id が設定されている場合、そのページのStorage Formatをテンプレートとして使用

## テンプレート取得モード（--setup）

既存のConfluenceページからテンプレートを取得する手順：

### 使い方

```
/confluence-req --setup https://xxx.atlassian.net/wiki/spaces/SPACE/pages/123456789/TemplatePage
```

または

```
/confluence-req --setup 123456789
```

### 処理フロー

1. mcp-atlassianの `confluence_get_page` でページを取得
2. Storage Format（XML）を抽出
3. テンプレート構造を解析して表示
4. 以下の選択肢を提示：
   - **A. このスキルに埋め込む** → スキルファイルを直接更新
   - **B. 外部ファイルに保存** → `~/.claude/templates/confluence-req-template.xml` に保存
   - **C. template_page_idとして設定** → 毎回ページから取得（常に最新）

### 外部テンプレートファイル

テンプレートを外部ファイルで管理する場合：

```
~/.claude/templates/
├── confluence-req-template.xml      # デフォルトテンプレート
├── confluence-req-template-projectA.xml  # プロジェクトA用
└── confluence-req-template-projectB.xml  # プロジェクトB用
```

プロジェクト固有のテンプレートを使う場合：
```
/confluence-req --template projectA
```

## 入力

以下のいずれかを受け取ります：
- Slackのやり取り
- 会議メモ・議事録
- ヒアリング内容のメモ
- 既存ドキュメントの内容

## テンプレート解決の優先順位

1. コマンドで指定されたテンプレート（`--template xxx`）
2. `template_page_id` が設定されている場合 → Confluenceから取得
3. 外部テンプレートファイル（`~/.claude/templates/confluence-req-template.xml`）
4. このスキルに埋め込まれたデフォルトテンプレート（下記）

## デフォルトテンプレート（Storage Format）

template_page_id や外部ファイルが未設定の場合、以下を使用：

```xml
<!-- 目次 -->
<ac:structured-macro ac:name="toc">
  <ac:parameter ac:name="printable">true</ac:parameter>
  <ac:parameter ac:name="minLevel">1</ac:parameter>
  <ac:parameter ac:name="maxLevel">3</ac:parameter>
</ac:structured-macro>

<h1>1. 概要</h1>
<ac:structured-macro ac:name="info">
  <ac:rich-text-body>
    <p>【ここにプロジェクト/機能の概要を1-2文で記載】</p>
  </ac:rich-text-body>
</ac:structured-macro>

<h1>2. 背景・目的</h1>
<ac:structured-macro ac:name="expand">
  <ac:parameter ac:name="title">詳細を表示</ac:parameter>
  <ac:rich-text-body>
    <h2>背景</h2>
    <p>【なぜこの機能が必要か】</p>
    <h2>解決したい課題</h2>
    <ul>
      <li>【課題1】</li>
      <li>【課題2】</li>
    </ul>
    <h2>期待される効果</h2>
    <ul>
      <li>【効果1】</li>
      <li>【効果2】</li>
    </ul>
  </ac:rich-text-body>
</ac:structured-macro>

<h1>3. 機能要件</h1>
<ac:structured-macro ac:name="expand">
  <ac:parameter ac:name="title">詳細を表示</ac:parameter>
  <ac:rich-text-body>
    <ul>
      <li>【機能要件1】</li>
      <li>【機能要件2】</li>
      <li>【機能要件3】</li>
    </ul>
  </ac:rich-text-body>
</ac:structured-macro>

<h1>4. 非機能要件</h1>
<ac:structured-macro ac:name="expand">
  <ac:parameter ac:name="title">詳細を表示</ac:parameter>
  <ac:rich-text-body>
    <h2>パフォーマンス要件</h2>
    <ul>
      <li>【要件】</li>
    </ul>
    <h2>セキュリティ要件</h2>
    <ul>
      <li>【要件】</li>
    </ul>
    <h2>可用性・信頼性要件</h2>
    <ul>
      <li>【要件】</li>
    </ul>
  </ac:rich-text-body>
</ac:structured-macro>

<h1>5. 画面仕様</h1>
<ac:structured-macro ac:name="expand">
  <ac:parameter ac:name="title">詳細を表示</ac:parameter>
  <ac:rich-text-body>
    <h2>画面構成</h2>
    <p>【画面構成の説明】</p>
    <h2>主要な画面要素</h2>
    <ul>
      <li>【要素1】</li>
      <li>【要素2】</li>
    </ul>
    <h2>画面遷移</h2>
    <p>【画面遷移の説明】</p>
  </ac:rich-text-body>
</ac:structured-macro>

<h1>6. スケジュール</h1>
<ac:structured-macro ac:name="expand">
  <ac:parameter ac:name="title">詳細を表示</ac:parameter>
  <ac:rich-text-body>
    <h2>マイルストーン</h2>
    <ul>
      <li>【マイルストーン1】</li>
      <li>【マイルストーン2】</li>
    </ul>
    <h2>リリース予定日</h2>
    <p>【日付】</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

## 処理フロー（通常モード）

1. テンプレートを解決（上記の優先順位に従う）
2. 入力情報を分析し、テンプレート構造に整理
3. 不明点・曖昧な点があれば確認を求める
4. 要件定義書の内容をユーザーに提示して確認（Markdown形式で見やすく表示）
5. 確認後、Storage Format（XML）に変換
6. Confluenceへの投稿：
   - デフォルト設定がある場合 → 設定値を使用
   - デフォルト設定がない場合 → スペースキー・親ページIDを確認
7. mcp-atlassianの `confluence_create_page` を使って投稿
   - `space_key`: スペースキー
   - `title`: ページタイトル（prefix + 機能名）
   - `content`: Storage Format形式の要件定義書
   - `parent_id`: 親ページID（設定されている場合）
8. 投稿完了後、作成されたページのURLを表示

## 投稿完了時のレスポンス

投稿が成功したら、以下の形式でレスポンスしてください：

```
✅ Confluenceに投稿しました

📄 ページタイトル: [タイトル]
🔗 URL: https://xxx.atlassian.net/wiki/spaces/SPACE/pages/PAGE_ID/PageTitle
```

※ URLは `confluence_create_page` のレスポンスから取得

## 使用例

### 基本的な使い方
```
/confluence-req

以下はSlackでのやり取りです：
...
```

### テンプレートをセットアップ
```
/confluence-req --setup https://xxx.atlassian.net/wiki/spaces/DEV/pages/123456789
```

### プロジェクト固有のテンプレートを使用
```
/confluence-req --template projectA

会議メモ：
...
```

## 注意事項

- 情報が不足している場合は、該当セクションに「TBD」と記載
- 推測で補完した箇所は明示する
- 投稿前に内容の確認を必ず行う（Markdown形式で表示し、OKならStorage Formatに変換）
- Confluenceの親ページIDは、ページURLの末尾の数字から取得可能
  - 例: `https://xxx.atlassian.net/wiki/spaces/DEV/pages/123456789/PageTitle` → ID: `123456789`
