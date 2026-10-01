# MarpとOVSテーマ

スライド制作の手順4〜5（代表の数枚・全体を組む）でMarkdownを書く前に全文読む。

## 目次

- 出力先と形式
- front matter
- テーマの解決
- 実装済みのクラス
- 表紙のテンプレート
- Marpの機能
- 図解素材とあふれの直し方
- 生成手順

## 出力先と形式

- 指定された出力先を使う。未指定なら作業ディレクトリの `slides/<topic>/` に保存し、採用した場所を伝える。
  既存成果物を確認し、今回の更新対象でなければ別名にする。
- 形式が未指定なら編集用Markdownと閲覧用HTMLを生成する。PDF・PPTXは指定された場合に追加する。
  検証用画像は一時ディレクトリに保存する。
- 編集可能なPowerPointが必要なら対応するプレゼンテーション制作スキルを使う。
  Marpの通常PPTXは各ページが画像になるため、編集可能なテキスト・図形の資料として案内しない。
  `--pptx-editable` は実験的な機能。LibreOffice Impressを要し、複雑なスタイルでは失敗し、ノートも移らない。
- 既存Google Slidesの編集やテンプレート準拠は専用スキルへ切り替える。

## front matter

ユーザー指定のテンプレートや視覚表現を優先する。指定がなければOVSの16:9を使う。

```yaml
---
marp: true
lang: ja
paginate: true
size: 16:9
theme: otake-visual
---
```

`lang: ja` は必須。省くとhtml要素が `en-US` になり、文節での改行（`word-break: auto-phrase`）が効かず、読み上げも英語になる。

寸法の目安は1280×720、左右72px・上下56pxの余白、8pxグリッド。
文字はスライドタイトル35〜42pt、本文18〜22pt、出典・注記などの補助情報は12〜14pt。
本文は短く、結論を先に置く。OVSの色・フォントは `tokens.json` 由来のテーマに任せ、スライドごとに追加しない。

## テーマの解決

テーマは `${XDG_CONFIG_HOME:-$HOME/.config}/otake/visual-system/generated/marp.css`。
dotfilesで未インストールの内容を検証するときはリポジトリ内の
`stow/design/.config/otake/visual-system/generated/marp.css` を使う。
生成済みCSSは直接編集しない（`themes/marp.css.tpl` を直して `node scripts/build.mjs` で再生成する）。
どちらにもなければテーマ未導入を伝え、一時的にMarp標準テーマで内容の草稿を作り、OVS確認済みとは報告しない。

## 実装済みのクラス

| 配置 | 実装済みクラス | 用途と注意点 |
| --- | --- | --- |
| 通常 | 指定なし | 主張、短い箇条書き、比較表、図解 |
| 表紙 | `lead` | 短い題名と目的。発表情報は `.meta` に入れる。装飾は置かない |
| 自己紹介 | `profile` | `.who`・`.body` のdivを置く（提案型は `.links` も）。テンプレートは [slides-self-intro.md](slides-self-intro.md) |
| 強調 | `invert` | 結論など短いメッセージ。表やコードは通常背景へ |
| 引用 | `quote` | 出典を示した実際の引用 |
| 2カラム | `columns` | 見出しと2つの直下要素。複数段落は左右それぞれをdivでまとめる |
| 時系列 | `timeline` | `.steps` の内側に `.step` と必要な `.date` |
| 数値 | `metric` | `.cards` の内側に `.card`、数値に `.value` |
| 例外の強調 | `.step.is-accent` / `.card.is-accent` | 時系列・数値カードの一か所だけ。強調色の枠と淡い背景になる |
| 面積配分 | `.ovs-balance` | 内側に `.canvas` `.primary` `.deep` `.soft` `.accent` のspanを置き、比率を `style="flex:数値"` で指定 |
| 章の現在地 | `_header` | 章名を並べ、現在の章だけ `**太字**` |

クラスだけではカードや時系列にならない。例えば数値カードには次のHTMLが必要。
HTMLタグを含むスライドの変換では `--html` を付ける。

```markdown
<!-- _class: metric -->

# 検証結果

<div class="cards">
  <div class="card"><div class="value">実測値</div><div>指標と単位</div></div>
  <div class="card"><div class="value">実測値</div><div>比較対象と期間</div></div>
</div>
```

- 色はクラスに任せ、スライド内で `style` に色を書かない。比率など数値の指定だけを許容する。
- 役割別の型（事例、二つのレーン、状態付きプロセスなど）の専用クラスは未実装。既存クラスと表・図解で組む。
- `org-chart` はOVSテーマに未実装。組織図はOVS図解として生成して配置する。

## 表紙のテンプレート

表紙はOVSの `lead` で組む。中央に題名と副題、左下の `.meta` に発表情報を置く。

- 題名は体言止めで短くし、改行位置はテーマに任せる（文節で折り返し、行の長さをそろえる）。
  意味の切れ目で必ず改行したい場合だけ `<br>` を使う。
- 副題は「何の話か」を1行で補う。題名の言い換えにしない。
- `.meta` の1行目は `**〈表示名〉**` だけにする。肩書は自己紹介スライドに任せ、表紙には載せない。
  2行目は `〈イベント名〉・〈発表日 YYYY-MM-DD〉`。
  社内資料など、イベント名がなければ発表日だけにする。〈〉の差し替え漏れは `ovs deck lint` がerrorにする。
- 色・位置は書かない。`.meta` の配置と縦線はテーマが付ける。

```markdown
<!-- _class: lead -->
<!-- _paginate: false -->

# 〈題名〉

〈副題〉

<div class="meta">

**〈表示名〉**
〈イベント名〉・〈YYYY-MM-DD〉

</div>

<!--
メモ: 〈想定時間〉。テーマ・流れ・結論を1行ずつ。
話す: 〈最初の一言〉
-->
```

## Marpの機能

| 目的 | 書き方 | 注意 |
| --- | --- | --- |
| 画像と文を左右に分ける | `![bg right:40%](assets/photo.jpg)` | 背景扱いでaltは読まれない。内容を持つ画像なら本文かノートで説明する |
| 箇条書きを1項目ずつ出す | 記号を `*` か `1)` にする | HTMLで発表するときだけ段階表示になる。PDF・画像では全項目が出る |
| 表紙・付録のページ番号を消す | `<!-- _paginate: false -->` | 参考資料スライドにも付ける |
| 発表者ビュー | HTMLを開いて `p` キー | ノートと次のスライドを別窓に出す |
| ノートを書き出す | `marp --notes slide.md -o notes.txt` | リハーサルの台本と時間計測に使う |
| PDFにノートとしおりを付ける | `--pdf-notes`・`--pdf-outlines` | 配布モードで補足を渡すとき |
| 見出しを枠に合わせて縮める | `# <!-- fit --> 見出し` | 短い強調の1枚だけに使う。本文のあふれ対策には使わない |

## 図解素材とあふれの直し方

- 図解素材が必要なときは [OVSスキル](../SKILL.md) のbrief作成・生成・lint手順を使う。
  スライド用の `slide` ターゲットを選び、本文に画像の内容を重複させない。
- 図のaltと出典を保持する。画像は縦横比を維持し、文字や根拠部分を切り取らない。
- 使う素材をスライドの `assets/` にコピーして相対参照にする。PDF・PNG変換では `--allow-local-files` を付ける。
- あふれは文章の整理、レイアウト変更、スライド分割を優先して直す。
  用途に応じた読みやすさと文字の階層を保てる範囲なら、余白を確保するためのサイズ調整も行う。
  一律縮小や `fit` だけで解決済みとせず、調整後の実際の表示を確認する。

## 生成手順

`marp` の存在とテーマの読み取り可否を確認する。以下は作成したMarkdownと同じ
ディレクトリで実行する例。出力指定とテーマに合わせて必要なコマンドだけ実行する。

```bash
slide_theme="${XDG_CONFIG_HOME:-$HOME/.config}/otake/visual-system/generated/marp.css"
marp --no-stdin --html --theme "$slide_theme" slide.md -o slide.html
# PDFを求められた場合
marp --no-stdin --html --theme "$slide_theme" slide.md -o slide.pdf
# PPTXを求められた場合
marp --no-stdin --html --theme "$slide_theme" slide.md -o slide.pptx
```

ローカル画像を含むPDF・PPTX・画像の変換は参照先が意図した素材であることを確認して
`--allow-local-files` を追加する。HTMLと素材は相対参照を保って一緒に渡す。
`marp` がなければMarkdownを完成させ、未変換の形式を伝える。勝手にインストールしない。

PDF・PPTX・PNGの変換と `ovs deck check` はブラウザー（Chromium）を起動する。
Codexなどのサンドボックスで起動に失敗した場合はサンドボックス外での実行を承認してもらう。
承認できなければHTMLまでを生成し、画像での表示確認は未実施と報告する。
