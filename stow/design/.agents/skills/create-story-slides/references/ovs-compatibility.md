# 既存OVSデッキの互換仕様

`theme: otake-visual` の資料を編集・再出力するときだけ読む。
構成、自己紹介の判定、検証の正本は [スキル本体](../SKILL.md)。
新規資料はStandardのL01〜L18を使い、既存資料のクラス・出力形式・素材は依頼なく移行しない。

## テーマと生成元

- 導入済みCSS: `${XDG_CONFIG_HOME:-$HOME/.config}/otake/visual-system/generated/marp.css`
- dotfiles内のCSS: `stow/design/.config/otake/visual-system/generated/marp.css`
- OVSビルドは `create-story-slides/assets/story-slides.css` と
  `visual-system/themes/marp.css.tpl` の互換定義を連結する。
  生成CSSは直接編集せず、共通の見た目はStandard CSS、互換クラスはOVS側で変更する。

```yaml
---
marp: true
lang: ja
paginate: true
size: 16:9
theme: otake-visual
---
```

## 既存クラス

| クラス | マークアップと用途 |
| --- | --- |
| 指定なし | 主張、短い本文、比較表、図解 |
| `lead` | 表紙。題名・副題と `.meta` 内の既存の発表情報 |
| `profile` | 自己紹介。左の `.who` と右の `.body`、任意の `.links` |
| `invert` | 短い結論や強調 |
| `quote` | 出典を示した引用 |
| `columns` | 見出しと2つの直下要素。複数段落は各divでまとめる |
| `timeline` | `.steps` 内に `.step` と必要な `.date` |
| `metric` | `.cards` 内に `.card`、数値に `.value` |
| `.step.is-accent` / `.card.is-accent` | 例外の一か所だけを強調 |
| `.ovs-balance` | `.canvas` `.primary` `.deep` `.soft` `.accent` の面積比 |
| `_header` | 既存の章表示。現在の章だけを太字にする |

StandardのクラスもCSSに含まれる。既存の構造を置き換えるためには使わない。
既存 `profile` は自己紹介判定でfullに相当する。MINI表記はcompactに読み替え、
判定をやり直して人物情報を追加・削除しない。人物の情報源と公開範囲は
[presenter-introduction.md](presenter-introduction.md) に従う。

```html
<div class="who">
  <img src="assets/photo.jpg" alt="登壇者の写真">
  <div>既存の表示名・肩書</div>
</div>
<div class="body">
  既存の自己紹介内容
</div>
```

既存素材は相対参照のまま維持する。新しいプロフィール値や画像を推測で補わない。
QRを更新する必要がある場合だけ既存の
[QR生成スクリプト](../../otake-visual/scripts/make-qr.swift)を利用できる。
これは素材生成への依存であり、自己紹介のルールをOVSへ戻すものではない。

## 出力と検証

形式は既存の納品形式を継承する。形式が分からない旧OVS資料は従来どおりHTMLを使う。
新規資料の既定形式、HTML・PDF・PPTXのコマンドは [marp-output.md](marp-output.md)、
検査は [review.md](review.md) に従い、`slide_theme` に上記のOVS CSSを設定する。
Standard専用の `scripts/build.sh` は旧OVSデッキに使わない。

OVSテーマがなければ所在を確認し、導入できない場合はMarkdownまで完成させて
未出力・未確認を報告する。既存テーマを無断で置き換えない。
