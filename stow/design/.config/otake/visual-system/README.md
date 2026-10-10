# Otake Visual System

記事、スライド、OGP、SNSの図解を「otake-sholの図」と分かる品質で、
MarkdownまたはJSONから繰り返し生成する個人デザインシステム。

Version 1.2.0 · Visual concept: **Standard — navy, blue, warm canvas**

## 最短の使い方

```bash
make install-design
exec zsh

ovs new design-system-article --part cover
ovs suggest design-system-article/article.md
ovs render design-system-article/design-system-article.brief.json
ovs preview design-system-article/dist
```

`ovs render`はSVG、PNG、同名の`.alt.txt`を一度に作る。編集するのはJSON brief。
生成済みSVGは直接編集しない。

## 用意されているもの

| 種類 | 内容 |
|---|---|
| 図解パーツ | 18種。基本12種 + Gantt、Roadmap、WBS、RACI、RAID、Status Board |
| チャート | 10種。bar、line、stacked-bar、dot、slope、scatter、heatmap、waterfall、small-multiples、progress |
| アイコン | 26種。基本20種 + マイルストーン、成果物、依存関係、スコープ、リソース、課題 |
| レシピ | 技術解説、比較・選定、データストーリー、振り返り、プロジェクト計画、週次ステータス |
| 出力先 | blog、Hatena、OGP、X、正方形、縦長、スライド、サムネイル |
| AI連携 | Claude `/visual`、Codex `$otake-visual` |
| スライド | create-story-slidesのStandard CSSを共有するMarpテーマと、描画を実測する検査（`ovs deck`） |
| ドキュメント | Markdown内のMermaidを共通SVGへ変換し、HTMLとMarpへ出力 |

パーツの判断基準は[PARTS.md](./PARTS.md)、見本は[EXAMPLES.md](./EXAMPLES.md)。

Markdownスライド制作はClaude `/slides` とCodex `source-command-slides` で共通化。
構成、テーマ、出力形式、表示確認は
[`create-story-slides`](../../../.agents/skills/create-story-slides/SKILL.md)で管理する。
新規資料はMarkdownとPDFを既定とし、既存OVS資料はテーマと形式を維持する。
媒体共通の原則は [デザインレビュー](../../../.agents/design/design-intent.md) を参照する。

## スライドを検査する

```bash
ovs deck outline slide.md --minutes 10                     # タイトル列と推定時間
ovs deck lint slide.md --minutes 10                        # 構成・文面・出典・時間の静的検査
ovs deck check slide.md --shots /tmp/slide-check           # 描画して実測し、枠付き画像と25%一覧を保存
ovs deck verify slide.md --minutes 10 --shots /tmp/slide-check   # lint＋check
ovs deck rules                                             # ルールと根拠
```

`check` はMarpでbareテンプレートのHTMLを作り、ヘッドレスChromeを
DevTools Protocolのパイプで操作して、はみ出し・枠での切れ・フッターやページ番号との衝突・
重なり・最終行の孤立・小さな文字・コントラスト・画像切れ・フォント未導入を測る。
追加の依存はなく、Chrome系ブラウザとmarpがあれば動く。errorがあると終了コード1を返す。
配布用の資料は `--mode read` で本文量の目安を切り替える。

## 記事から作る

### 1. 図の候補を出す

```bash
ovs suggest examples/article.md
ovs list recipes
```

候補は見出しと語彙による初期案。すべて採用せず、文章だけでは関係が伝わりにくい箇所へ絞る。

### 2. briefを書く

```bash
cp templates/brief.json topic.brief.json
```

最低限決めるもの:

- `intent.message`: 図だけを見た読者に残す一文
- `meta.part`: 伝える関係に合うパーツ
- `content`: 短いタイトルとスロット
- `source`: 出典。自作は「筆者作成」
- `accessibility.alt`: 結論と関係が分かる12〜300文字
- `output`: 媒体と形式

スキーマは`schemas/brief.schema.json`。

### 3. 生成して確認する

```bash
ovs render topic.brief.json --out assets
ovs lint assets
ovs contrast assets
ovs preview assets --out assets/gallery.html
```

同名ファイルがある場合は安全のため停止する。内容を確認して更新する場合だけ
`--force`を付ける。シンボリックリンクは`--force`でも上書きしない。

## 図解のコントラスト検査

`ovs contrast <SVG|DIR>` はChromeでSVGを描画し、文字の字形がある画素の背景と文字色を比較する。
継承色、入れ子の変形、`tspan`、複数の背景面を扱い、問題の文字・座標・比率を報告する。
`--json` では背景色・文字色・判定基準も取得できる。入力と生成物は変更しない。

通常文字は4.5:1、大きな文字は3:1を基準とする。
大きさは出力寸法と変形を反映し、24px以上または太字18.67px以上で判定する。
根拠は[WCAGのContrast Minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)。
アンチエイリアスの縁を除いた字形内部で最も低い比率を採用する。

透明な背景、画面外の文字、文字の輪郭線などで測定できない場合も終了コード1を返す。
後から描かれた図形が文字を覆う場合も、図形と字形マスクの重なりとして失敗させる。
背景を白と仮定して合格にしない。検査対象は安全性検証を通過したOVSネイティブSVGだけ。
Mermaid SVG、画像内の文字、文字同士の重なり、フォント代替の妥当性は検査対象外。
結果は実行環境のフォントに依存し、目視確認を置き換えるものではない。
Chrome系ブラウザが必須。`PUPPETEER_EXECUTABLE_PATH` でも実行ファイルを指定できる。

## データからチャートを作る

CSV:

```csv
category,value
記事 A,81
記事 B,61
```

生成:

```bash
ovs chart data.csv \
  --type bar \
  --title "記事別の読了率" \
  --unit "%" \
  --period "2026年1–6月" \
  --source "アクセス解析" \
  --alt "記事Aが81%で最も高く、記事Bが61%で続く横棒グラフ。" \
  --target blog,ogp \
  --out assets
```

装飾用の疑似データは使わない。`slope`は`start,end`、`scatter`は`x,y`、
複数系列は`series,category,value`を使う。

## プロジェクトマネジメント図を作る

ガントはタスクCSVまたはJSONから直接生成する。日本語の状態
`未着手`、`進行中`、`遅延`、`完了`も利用できる。

```csv
id,task,start,end,owner,status,progress,dependsOn,milestone
design,設計,2026-08-01,2026-08-07,Design,完了,100,,false
build,実装,2026-08-08,2026-08-21,Dev,進行中,45,design,false
release,公開,2026-08-22,2026-08-22,PM,未着手,0,build,true
```

```bash
ovs gantt tasks.csv \
  --id release-plan \
  --title "新機能リリース計画" \
  --today 2026-08-12 \
  --target blog,slide \
  --out assets
```

`dependsOn`はfinish-to-start依存で、複数指定時に`task-a|task-b`と書く。
後続タスクは依存タスクの終了翌日以降に開始する。循環依存、未知の依存先、
不正な日付、0〜100外の進捗は生成前に拒否する。1枚は8タスクまでとし、
超える場合はフェーズで分割する。`id`は半角小文字・数字・ハイフン、
タスク名は16文字、担当名は12文字以内にする。

```bash
ovs list pm
ovs list recipes
```

WBS、RACI、RAID、週次ステータスは専用パーツを使う。マイルストーンは
`timeline`、バーンダウンは`line`、ステークホルダーマップは`matrix`、
依存関係マップは`architecture`も再利用できる。

## MarkdownとMermaidからHTML・Marpを作る

通常のMarkdownへMermaidコードブロックを書く。図ごとに`accTitle`と
12〜300文字の`accDescr`を指定する。安定したファイル名が必要な場合は
`ovs-id`、図ごとの出典は`ovs-source`コメントを加える。

````markdown
# ドキュメント生成

```mermaid
flowchart LR
  %% ovs-id: document-flow
  %% ovs-source: 筆者作成
  accTitle: OVSドキュメント生成フロー
  accDescr: Markdown内のMermaidを共通SVGへ変換し、HTMLとMarpで共有する処理フロー。
  A[Markdown] --> B[OVS document]
  B --> C[HTML]
  B --> D[Marp]
```
````

生成:

```bash
ovs document examples/document.md --target html,marp --out dist
```

```text
dist/
├── assets/
│   ├── document-flow.svg
│   └── ovs.css
├── document.html
├── document.marp.md
└── document.marp.html
```

Mermaidは`generated/mermaid.json`、通常HTMLは`generated/html.css`、
Marpは`generated/marp.css`を使う。図とHTMLの色・書体は`tokens.json`、Marpの共通デザインはcreate-story-slidesのCSSを使う。
両者の一致を`make design-check`で検査する。Mermaid SVGには`securityLevel: strict`を適用し、
外部参照、スクリプト、`foreignObject`、イベント属性を出力前に拒否する。
Mermaid内のfront matter／設定directiveによるテーマ上書きと、Markdown本文の
危険な生HTML、front matter／MarpコメントからのCSS注入も拒否する。
生HTMLは`abbr`、`br`、`details`、`kbd`、`mark`、`sub`、`summary`、`sup`
だけを許可し、Marp directiveコメント内では生HTMLを許可しない。
実行可能スキームと文字参照を含むMarkdownリンクも拒否する。HTMLコード例は
フェンス付きコードブロックへ入れる。

`--target html`または`--target marp`で片方だけ生成できる。全図に共通の出典は
`--source "筆者作成"`で指定する。既存出力の更新は対象を確認して
`--force`を付ける。Marpは記事を自動でスライド分割しないため、同じMarkdown内へ
`---`の区切りを置き、1スライド1メッセージ・1図を目安にする。

## 媒体別に書き出す

```bash
ovs export visual.svg --target hatena,ogp,x,square,vertical,slide,thumbnail
```

| target | px | 用途 |
|---|---:|---|
| `blog` / `hatena` | 1200 × 675 | 記事本文 |
| `ogp` | 1200 × 630 | OGP |
| `x` | 1600 × 900 | X投稿 |
| `square` | 1080 × 1080 | 正方形SNS |
| `vertical` | 1080 × 1350 | 縦長SNS |
| `slide` | 1280 × 720 | 16:9スライド |
| `thumbnail` | 600 × 338 | 一覧サムネイル |

縦横比が違う媒体は背景を拡張し、図の内容を切らない。compact媒体では補足文を省く。

## 視覚文法

[create-story-slidesのStandard仕様](../../../.agents/skills/create-story-slides/references/design-system.md)を全媒体のデザインの正本とする。

1. Warm Canvasの本文面、Primary Blueの表紙、Deep Navyの結論
2. Mist Grayの細い境界と余白。太い輪郭・オフセットシャドウ・装飾の見出し線は使わない
3. Zen Maru Gothicの見出し、Noto Sans JPの本文・チャート、Plus Jakarta Sansの主要数値
4. オレンジは例外・変化・行動だけ。通常の系列・進捗は青・濃紺とラベルで示す
5. 図の出典・altと右下の小さな鍵盤マーカーを保持

`tokens.json`の旧色名（wine、mint、mango、violetなど）は互換用。
現在はStandardの11色へ対応し、旧配色は出力しない。
図の基準座標1200×675と媒体別サイズを保ち、スライドは1280×720へ出力する。
図の文字サイズは媒体別の密度に合わせ、スライド全体の文字階層はStandardのCSSで管理する。

## CLI

```text
ovs new <slug>                 記事とbriefの雛形を作る
ovs suggest <article.md>       パーツと記事レシピを提案
ovs render <brief.json>        SVG・PNG・altを生成
ovs chart <data.csv|json>      実データからチャートを生成
ovs gantt <tasks.csv|json>     タスクからガントを生成
ovs document <file.md>         MermaidをHTML・Marpで共有
ovs export <file.svg>          媒体別サイズへ展開
ovs preview [dir]              HTMLギャラリーを生成
ovs lint <svg|dir>             安全性・構文・altを検証
ovs contrast <svg|dir>         文字と背景のコントラストを実測
ovs list <kind>                パーツ等の一覧を表示
ovs deck <outline|lint|check|verify|rules> <slide.md>   Marpスライドを検査
```

`render`、`chart`、`gantt`、`document`、`export`、`preview`、`suggest --write`は
既存出力を上書きしない。
再生成は対象を確認して`--force`を付ける。書込みは同じディレクトリ内で原子的に行う。

## 唯一の正と生成物

```text
tokens.json
icons.json
components/*.svg.tpl
templates/*.svg.tpl
create-story-slides/assets/story-slides.css + themes/marp.css.tpl
themes/html.css.tpl
recipes/*.json
schemas/brief.schema.json
        │
        ├─ scripts/build.mjs
        │    └─ generated/{tokens,templates,icons,html,marp,mermaid,manifest}
        └─ scripts/ovs.mjs
             └─ SVG + PNG + alt + gallery + HTML/Marp document
```

ブランドの変更はStandard仕様とCSSに反映してから`tokens.json`を同期する。
生成物へ色・フォントを直接追加しない。アイコンは`icons.json`、
テンプレート構造は`templates/*.svg.tpl`、描画判断はCLIへ集約する。

## 検証

```bash
# visual-systemディレクトリで生成物を更新
node scripts/build.mjs
node scripts/build.mjs --check

# 以下はdotfilesリポジトリルートで実行
make design-test DESIGN_TESTS=stow/design/.config/otake/visual-system/test/contrast.test.mjs
make design-mutation
make design-check
make validate
```

編集中は`make design-test`でテストだけを実行し、`DESIGN_TESTS`で変更に対応するファイルへ絞る。
この短い検証では生成物の同期や18テンプレートの実測まで完了したとは扱わない。
コミット前は必ず`make validate`を実行する。全体検証は`DESIGN_TESTS`を指定しても対象を縮小しない。
成功後に変更・失敗・未解決の懸念がなければ再実行せず、未実行やスキップを成功と区別して報告する。

`make design-check`はStandardとの配色・フォント一致、トークン同期、JSON briefからの18パーツ生成、10チャート、
データ駆動ガント、SVG XML、安全属性、320px描画、Marpテーマを確認する。
さらに`make design-contrast`を実行し、18テンプレートの文字と背景を実測する。
Chromeがなければ検証を失敗させる。全10チャートとデータ駆動ガントも描画テストの対象。

`make design-mutation`は一時ディレクトリの検査器に、コントラスト判定の無効化、
文字サイズによる基準の逆転、文字を覆う図形の見逃しを1つずつ加える。
改変前の回帰テストが成功し、3種類の改変それぞれで既存テストのアサーションが失敗することを確認する。
構文エラー・Chrome起動失敗・タイムアウトを検出成功と扱わず、改変を見逃した場合も失敗する。
元ファイルは変更しない。検査器やそのテストの編集時に実行し、`make design-check`経由の全体検証にも含める。
対象はこの3種類の回帰であり、検査器全体のミューテーションスコアではない。

公開前の受け入れ基準:

- 1図1メッセージ
- 320px幅でも見出しと主要値が読める
- 色だけに依存せず、線・位置・ラベルでも関係を追える
- 実データに単位、期間、出典がある
- SVG、PNG、altが揃う
- 第三者の固有表現や著作物をトレースしていない

## 安全性

- SVGの`script`、`foreignObject`、外部画像、イベント属性、外部参照を拒否する
- SVG要素・属性を許可リストで検査し、`xmllint --nonet`でもXML構文を確認する
- 個人情報、秘密情報、未公開業務データをbriefへ入れない
- 出典不明のデータは公開しない
- 1枚8ノード、4系列を目安の上限にする
- ラベルが長い場合は図を詰めず、説明を本文へ戻す
