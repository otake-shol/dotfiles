# 見た目：配色・アイコン・ロゴ

## テーマ

`themes/story-slides-warm.css`（slides リポジトリ）を使う。story-slides を `@import` し、色のトークンだけを上書きしている。
レイアウト・文字の大きさ・余白は story-slides と同じなので、create-story-slides の layout-catalog と marp-output をそのまま使う。

```yaml
theme: story-slides-warm
```

```bash
marp --no-stdin --theme-set themes --theme themes/story-slides-warm.css --html --allow-local-files <md> -o <out>
ovs deck check <md> --theme themes/story-slides-warm.css   # ovs はテーマのフォルダを自動でテーマセットに入れる
```

別のリポジトリに置く場合は、`story-slides.css` と `story-slides-warm.css` を同じ `themes/` に入れる。

## 配色の役割

| トークン | 色 | 役割 |
| --- | --- | --- |
| `--primary-blue` | テラコッタ `#B0502C` | 構造・現在地（N01）・アイコン・線・表紙の面 |
| `--deep-navy` | 焦げ茶 `#3B2A22` | 章扉・帯（`band`）・濃い面 |
| `--accent-orange` | 青緑 `#1F6F6A` | 注意・変化・行動（`exception`）。主役が暖色なので寒色で目立たせる |
| `--primary-soft` / `--pale-blue` | 淡いテラコッタ | 薄い面・カード |
| `--accent-soft` | 淡い青緑 | `exception` の面 |
| `--warm-canvas` | 生成り `#F8F5EE` | 背景 |
| `--ink` / `--muted-ink` | 暖かい黒・灰 | 本文・補足 |

- トークン名は元テーマに合わせて残している（`--primary-blue` がテラコッタになる）。新しいCSSを書くときもトークンで指定する。
- インラインSVGはトークンを使えないので、上の色コードを直接書く。story-slides の色（`#2C63B4`・`#123858`・`#ECF2F9`・`#D5DDE6`）が残っていないかを `grep` で確かめる。

## アイコン

Lucide（ISC）をテラコッタで取得する。

```bash
ICON_COLOR='#B0502C' ~/.agents/skills/create-story-slides/scripts/fetch-icons.sh <assets> <名前>...
```

- 置き方：3列の項目は `<img class="ico-lg">` を項目の先頭に、`contrast` の見出しは `### <img class="ico"> 見出し`。同じ役割のアイコンは同じ大きさにする。
- alt は必ず内容を説明する文にする（「虫眼鏡のアイコン」など）。空の alt は ovs deck lint の error になる。
- L01・L03・L12・L17・L18 には置かない（create-story-slides の決まり）。
- 使わなかったアイコンは削除し、版と使った場所を README の素材の出典に書く。

参照実装で使った意味とアイコンの対応（同じ意味には同じアイコンを使う）：

| 意味 | アイコン |
| --- | --- |
| 書く／まとめる／考える | `pen-line` / `file-text` / `lightbulb` |
| 何に使う？／どう始める？／間違えない？ | `compass` / `log-in` / `shield-check` |
| 検索／Claude（会話） | `search` / `message-circle` |
| 一言だけ／条件を足す | `message-square` / `list-checks` |
| 気軽に頼める／入れる前に確認 | `circle-check` / `shield-alert` |
| プロジェクト／アーティファクト | `folder-open` / `app-window` |

## ロゴと公式色

Claude・Anthropicのロゴ（マーク）、Claudeの公式色、公式の書体は使わない。

- 根拠：[Anthropic Trademark Guidelines](https://www.anthropic.com/legal/trademark-guidelines)（2024-08-01施行、2026-11-01確認）。名前・ロゴ・ブランド要素は Anthropic が許可した使い方で、事前に承認した資料でしか使えず、後援・推薦・提携を示す使い方もできない。商標記号（™・®）も付けない。
- 製品名「Claude」を説明のために書くのはよい。表紙や見出しで公式の研修に見せる言い方（「公式」「認定」など）はしない。
- claude.ai やアプリの実画面に写るマークは、製品の操作を説明するための画面として残す。マークだけを切り抜いて飾りに使わない。
- create-story-slides の「Logos for named products」は、このスキルでは Claude・Anthropic には適用しない。他社の製品（GitHub・Slack など）のロゴは create-story-slides の決まりに従う。
- クライアント向けの有料研修では、講師ガイドの差し替えに「Anthropicの公式研修ではない」ことを口頭で伝える一文を入れる。
- ガイドラインが更新されていないかを、キットを大きく改訂するときに確かめる。

## 実画面の見せ方

- 実画面は `<img class="shot">` で置き、判断に必要な部分だけを切り抜く。2枚を1ページに並べると文字が読めなくなるので、1ページ1枚にする。
- 何を見るか（入力欄、送信ボタン、返事の位置）は見出しと帯で言葉にする。画像の上に矢印や枠を描き足さない。
- 撮影条件はスライドに表示しない。発表者ノートと README に書く。
