# 成果物契約

## ディレクトリ構成

```text
channel-root/
├── channel.json
├── channel-notes.md
├── episodes/
│   └── YYYY-MM-DD-slug/
│       ├── episode.json
│       ├── brief.md
│       ├── research.md
│       ├── review.md
│       └── performance.md
├── library/
│   ├── visuals/
│   ├── characters/
│   ├── audio/
│   └── prompts/
└── logs/
    └── corrections.jsonl
```

`scripts/youtube_ops.mjs`は既存の`channel.json`またはepisodeディレクトリを上書きしない。

## `channel.json`

- `schema_version`: 現在は`1`
- `channel`: 名前、動画の約束、主言語、対象視聴者、テーマの柱、除外範囲
- `editorial`: 語り口、タイトル規則、禁止表現、情報源方針、公開頻度
- `characters`: 任意の話者定義。ID、役割、口調、禁止表現、音声方針、原画参照、登場制約
- `visual_system`: 長尺とShortsの比率、利用可能なtemplate ID、brand token
- `integrations`: 任意。学習プロダクトなど外部成果物との接続契約
- `human_gates`: 人間の承認が必要な工程

チャンネルの最新状態をプロンプトへコピーして二重管理しない。プロンプトやスキルから必要なフィールドを読む。

キャラクター原画を別リポジトリで管理する場合は`asset.authority`、リポジトリ相対の`asset.path`、`sha256:`形式の`asset.revision`を記録する。`presentation`へ1画面の最大数、登場箇所、除外箇所、加工規則、動き、Reduced Motion時の扱いを置く。

## `episode.json`

### 基本情報

- `schema_version`: 現在は`1`
- `id`: `YYYY-MM-DD-slug`
- `status`: `seed`、`researched`、`outlined`、`scripted`、`visualized`、`packaged`、`approved`、`published`、`measured`
- `created_at`、`updated_at`: `YYYY-MM-DD`

### 企画

`topic`へworking title、本人の意図、対象視聴者、視聴者の課題、動画の約束、独自の切り口、除外範囲を置く。

### 根拠

`sources`の各要素は一意なID、タイトル、URL、発行主体、公開日、確認日、種別、メモを持つ。`claims`の各要素は一意なID、文、分類、source ID、確度、検証メモを持つ。

### 構成と台本

`outline`の各要素はsection ID、タイトル、役割を持つ。`script.lines`の各要素はline ID、section ID、話者、セリフ、感情、visual ID、source IDを持つ。

キャラクターを使う場合は`character_direction`へcharacter ID、ナレーション方式、音声選定状態、登場するsection、区切りで登場するsection、非表示にするコンテンツ種別を置く。

### ビジュアル

`visuals`の各要素はvisual ID、型、template ID、目的、画面内容、asset path、source ID、QA状態を持つ。画面内容を自由形式の実装コードにせず、レンダラーが解釈できるデータとして保持する。

### パッケージ

`packages.long`へタイトル候補、選択したタイトル、説明文、サムネイル、チャプターを置く。`packages.shorts`へShortsごとのID、hook、`script_lines`、`visual_ids`、CTAを置く。

### レビューと運用

- `reviews`: AIと人間のレビュー結果。stage、reviewer、status、findings
- `human_gates`: `concept`、`outline`、`master_script`、`thumbnail`、`publish`の状態
- `publication`: 公開先、URL、公開日時
- `metrics`: 取得日時と公開後指標
- `correction_log_ids`: `logs/corrections.jsonl`との対応

### 学習プロダクト連携

動画から教材や演習へ接続する場合だけ`learning_target`を持たせる。`integration_id`、教材の対象ID、図解ID、有効期限、着地先、CTA、許可された匿名計測軸を記録する。詳細は[学習プロダクト連携](learning-product-integration.md)を参照する。

ローカル教材をsourceにする場合は`kind: "local"`とし、`path`、`locator`、`revision`を使う。`path`は教材リポジトリからの相対パス、`revision`は参照箇所の`sha256:`値とする。端末固有の絶対パスを保存しない。

## 状態遷移

後続状態へ進める前に前工程の成果物を揃える。

| 状態 | 必須成果物 |
|---|---|
| `seed` | topicの意図、対象、課題、約束、切り口 |
| `researched` | sources、claims、事実claimの出典 |
| `outlined` | 3セクション以上のoutline |
| `scripted` | sectionへ接続したscript line |
| `visualized` | 全lineのvisual割り当てとvisual QA |
| `packaged` | 3タイトル候補、選択タイトル、サムネイル、Shorts |
| `approved` | 全人間ゲートの承認、重大指摘ゼロ |
| `published` | 公開日時とURL |
| `measured` | 取得日時と公開後指標 |

`status`を進める操作と検証を同じ操作にしない。検証結果を確認してから人間または上位ワークフローが状態を更新する。

## correction log

1行1JSONで次を記録する。

```json
{"id":"corr-001","timestamp":"2026-09-04T12:00:00+09:00","episode_id":"2026-09-04-example","stage":"title","artifact_path":"episode.json#/packages/long/selected_title","before":"抽象的な案","after":"固有名詞を含む案","reason":"対象が伝わらない","category":"abstract-title","rule_candidate":"タイトルへ対象の固有名詞を含める","promoted_to":null}
```

`before`と`after`へ秘密情報や未公開の個人情報を入れない。
