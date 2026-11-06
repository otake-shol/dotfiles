# OKF v0.2 仕様の要約

Open Knowledge Format（OKF）は Google Cloud が2026年6月に公開した、AIエージェントに知識を渡すための文書形式。専用のDBやSDKは要らず、YAML frontmatter つき Markdown のディレクトリだけで成り立つ。

- 正: [GoogleCloudPlatform/open-knowledge-format](https://github.com/GoogleCloudPlatform/open-knowledge-format)（2026年に独立リポジトリへ移行）
- この要約の元: [knowledge-catalog/okf/SPEC.md](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)（Version 0.2。移行前の凍結スナップショット）
- 確認日: 2026-11-06。新リポジトリの SPEC.md とは差分を未確認。仕様の改版を見つけたらこのファイルと `scripts/check-okf.mjs` を同じコミットで直す

## バンドルと ID

- バンドル = Markdown ファイルのディレクトリツリー。構造は領域ごとに自由に決める。git リポジトリ、zip、大きなリポジトリのサブディレクトリのどれでもよい
- **概念 ID = バンドル内のパスから `.md` を除いたもの**（例: `tables/customers`）。ファイル名以外の命名規則は無い
- 予約名: `index.md`（ディレクトリの一覧）と `log.md`（更新履歴）。どの階層にも置ける。概念文書には使わない。それ以外の `.md` はすべて概念
- `references/` は慣例名（外部資料、実行手順、コードの置き場）で必須ではない

## frontmatter

ファイル先頭を `---` で囲む UTF-8 の YAML。

| キー | 区分 | 内容 |
| --- | --- | --- |
| `type` | **必須（唯一）** | 自由記述の種別。例: `BigQuery Table`, `API Endpoint`, `Metric`, `Playbook`, `Reference`。利用側は未知の type を受け入れる |
| `title` | 推奨 | 表示名。無ければファイル名から導く |
| `description` | 推奨 | 1文の要約。index.md の各行にも使う |
| `resource` | 推奨 | 実体の正規 URI。抽象概念なら省く |
| `tags` | 推奨 | 短い文字列のリスト |
| `generated` | 任意 | `{ by: <actor>, at: <ISO 8601 UTCオフセット付き> }`。`by` は必須 |
| `verified` | 任意 | `{ by, at }` のリスト（単体マッピングも1要素のリスト扱い） |
| `status` | 任意 | `draft` / `stable` / `deprecated`。省略時は `stable` |
| `stale_after` | 任意 | ISO 8601 の日時。この時刻を過ぎたら古い扱い |
| `sources` | 任意 | 出典のリスト。各要素は `resource`（必須: URL・バンドル内パス）と任意の `id`・`title`・`author`・`last_modified` など |

- 独自キーを足してよい。利用側は未知のキーで拒否してはならない
- actor の書き方: エージェントは `<producer>/<version>`、人は `human:<id>`、自動処理は `process:<id>`
- 信頼の段階: `verified` 無し = 未検証、`human:` 以外の検証者のみ = 機械確認、`human:` を含む = 人がレビュー済み
- 計算手順を持つ概念（`type: Attested Computation`）だけは `runtime` も必須。普段は使わない

## 本文

- 普通の Markdown。必須の見出しは無い。当てはまるときは `# Schema`, `# Examples`, `# Computation` を慣例として使う
- 主張ごとの出典は脚注で示し、ラベルに `sources[].id` を使う（例: 本文 `[^ga4-schema]`、定義 `[^ga4-schema]: GA4 BigQuery Export schema`）

## リンク

- 普通の Markdown リンク。`/` 始まりのバンドル内絶対パス（推奨。例: `[customers](/tables/customers.md)`）か相対パス
- リンクは種類の無い関係を表す。関係の種類は本文で説明する
- リンク切れは許容される（利用側はエラーにしない）

## index.md と log.md

- `index.md`: 任意。frontmatter は書かない。ただしバンドル直下の `index.md` だけは `okf_version: "0.2"` を書いてよい。本文は `# 節` 見出しと `* [Title](相対URL) - description` の箇条書き
- `log.md`: 任意。日付ごとのまとまりを新しい順に並べる。見出しは `## YYYY-MM-DD`。各項目は文章で書き、先頭に **Update** / **Creation** / **Deprecation** / **Initialization** などの太字を置く

## 適合の条件

予約名以外のすべての `.md` が解析できる frontmatter と空でない `type` を持ち、`index.md`・`log.md` が上記の形に従っていれば適合。任意項目の欠落、未知の type、余分なキー、リンク切れ、index.md の欠落では不適合にならない。

## 例（仕様 §4.3 より）

```markdown
---
type: BigQuery Table
title: Customer Orders
description: One row per completed customer order across all channels.
resource: https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders
tags: [sales, orders, revenue]
generated: { by: reference_agent/gemini-2.5-pro, at: 2026-05-28T14:30:00Z }
---

# Schema

| Column        | Type      | Description                              |
|---------------|-----------|------------------------------------------|
| `order_id`    | STRING    | Globally unique order identifier.        |
| `customer_id` | STRING    | Foreign key into [customers](/tables/customers.md). |

# Joins

Joined with [customers](/tables/customers.md) on `customer_id`.
```
