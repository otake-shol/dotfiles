---
name: okf
description: 知識ドキュメントを OKF（Open Knowledge Format：1概念1ファイルの Markdown＋YAML frontmatter、type 必須）で書く・直す・検査する。「OKFで書いて」「OKF形式にして」「ドキュメントをAIエージェントが読める形に整理して」「docs/ にナレッジを追加して」「OKFに準拠しているか検査して」などで使う。dotfiles の docs/ と、OKF を採用したリポジトリが対象。Obsidian Vault のノート作成は Vault のスキーマとテンプレートを優先し、OKF との対応だけをここで確認する。スライドは create-story-slides、技術ブログは technical-blog-writing を使う。
---

# OKF で知識ドキュメントを書く

OKF は AIエージェントに知識を渡すための文書形式。1つの概念を1つの Markdown にし、先頭の frontmatter に種別（`type`）を書く。ファイルのパスがそのまま概念の ID になる。

仕様の詳細は [references/spec.md](references/spec.md)。検査は `scripts/check-okf.mjs` が行い、判定は spec.md に合わせる（spec.md が正）。

## 手順

1. **バンドルを特定する**: 対象のディレクトリ（例: dotfiles の `docs/`）を決める。バンドル直下に `index.md` が無ければ作る（下記「index.md と log.md」）
2. **1概念1ファイルに分ける**: 1ファイルに複数の話題が混ざっていたら分割する。ファイル名は内容を表す短い kebab-case にする（パスが ID になり、リンク先として長く残るため）
3. **frontmatter を書く**: 雛形は [assets/concept.md](assets/concept.md)。`type` は必須。`title`・`description`・`tags` は既定で書く
4. **本文を書く**: 普通の Markdown。他の概念へのリンクは `/` 始まりのバンドル内パスで書く（ファイルを移動しても書き方が揺れないため）
5. **index.md と log.md を更新する**: 追加・削除・名前変更した概念を index.md に反映し、log.md に日付つきで記録する
6. **検査する**: 下記コマンドでエラー0を確認する。警告は内容を見て直すか、理由を添えて残す

```bash
node ~/.agents/skills/okf/scripts/check-okf.mjs <bundle-dir>
# dotfiles の docs/ は make docs-check（make validate にも含まれる）
```

## 確認する項目と既定値

| 項目 | 扱い |
| --- | --- |
| バンドルの範囲 | 依頼から決まらなければ確認する |
| `type` の値 | 既定値で進める。既存バンドルにある値を優先し、無ければ下表から選ぶ |
| `status` | 書きかけは `draft`、それ以外は省略（省略時は `stable`） |
| `generated` | AI が下書きした概念には書く（`{ by: claude-code/<model>, at: <ISO 8601> }`）。人が書いたものには書かない |
| `verified` | 利用者が内容を確認したと言ったときだけ書く（`human:<id>`）。AI が自分で確認済みにしない（信頼の段階を偽ることになるため） |
| `sources` | 外部資料に基づく概念には書く。URL と確認日を残す |

## type の選び方

OKF は type の値を決めていない。このリポジトリでは次を使う（揃えておくと index.md と検索で種別がまとまるため）。

| type | 使う場面 |
| --- | --- |
| `Guide` | 規約、設計方針、使い方の説明 |
| `Playbook` | 手順書、運用手順、障害対応 |
| `Reference` | 外部仕様・資料の要約、一覧表 |
| `Decision` | 判断の記録（ADR に当たるもの） |

当てはまらないときは新しい値を作ってよい。作ったらこの表に足す。

## index.md と log.md

- `index.md` に frontmatter は書かない。バンドル直下の `index.md` だけは `okf_version: "0.2"` を書く
- `index.md` の本文は `# 節` と `* [title](相対パス) - description` の箇条書き。description は各概念の frontmatter と同じ文にする
- `log.md` は `## YYYY-MM-DD` 見出しを新しい順に並べ、各行の先頭に **Creation** / **Update** / **Deprecation** を置く

## NG例・OK例

- NG: `README.md` に複数の話題を足し続ける → OK: 話題ごとに概念ファイルを作り、README からはリンクする
- NG: `index.md` や `log.md` を概念として書く（frontmatter に type を書く） → OK: 予約名は一覧と履歴だけに使う
- NG: リンクを `../../docs/x.md` のように書く → OK: バンドル内は `/x.md` で書く
- NG: AI が書いた概念に `verified: { by: human:... }` を付ける → OK: `generated` だけを付け、確認は利用者に頼む

## 参照先

- [references/spec.md](references/spec.md): frontmatter のキー一覧、リンク、適合条件を確かめるとき
- [references/obsidian.md](references/obsidian.md): Obsidian Vault のノートを OKF の観点で扱うとき（Vault は wikilink と独自の status を維持する）
