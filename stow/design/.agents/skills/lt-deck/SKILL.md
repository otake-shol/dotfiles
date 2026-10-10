---
name: lt-deck
description: ネタ（話題）から10分前後のLTスライドを素早く作る。材料集め（自分のリポジトリ・git log・公式ドキュメント）、slidesリポジトリへの雛形作成、create-story-slidesでの作成、図解・実画面・アイコン・実データのグラフ、検査、コミット、Slack共有用PDFまでを一続きで進める。「このネタでLT作りたい」「LTスライドをパッと作って」「次のミートアップ用の資料」などで使う。既存LTの修正にも使う。
---

# LT Deck

ネタを受け取ったら、材料を自分で確かめて集め、create-story-slides の型で10分のLTに仕上げ、検査して共有できる状態まで進める。
スライドの書き方・デザイン・型の判断は create-story-slides に従う（作成前に必ず読み込む）。このスキルはLTを素早く作るための段取りと、手元の環境の決まりを持つ。

## 前提（この環境の決まり）

- 置き場所：slides リポジトリ（既定 `~/01_development/slides/repository`、`SLIDES_REPO` で変更可）の `slides/<年>-<slug>-lt/`。原稿は `deck.md`、付録は `appendix.md`。
- テーマ：`themes/story-slides.css`（create-story-slides と同じ）。既存のLT（effort・dotfiles・statusline）と見た目をそろえる。
- 自己紹介：非公開のプロフィール `~/.config/dotfiles-local/claude/slides/self-intro.md` の `lt-profile` ブロックをそのまま使う。発表者ノートの最後の一文だけ本題につなぐ。公開リポジトリ（dotfiles）に個人情報を書かない。
- イベント：既定は `Kagoshima | Claude Meetup`。主催者に触れる一文はこのイベント向けなので、別のイベントでは差し替える。
- 日付が未定なら表紙と終幕の `〈YYYY-MM-DD〉` を残す（検査のerrorは意図どおり）。決まったら埋める。
- push と Slack への共有は、ユーザーの指示があってから行う。

## 進め方

次のチェックリストを回答に写し、進めながら更新する。

```text
LT作成:
- [ ] 1. 材料：ネタの一次情報を集め、数値は自分で数え直す（集計日を残す）
- [ ] 2. 骨組み：中心メッセージ1文、題名、章4〜5、タイトル列を決めて短く示す
- [ ] 3. 雛形：scripts/new-lt.sh <slug> "<題名>" で作る
- [ ] 4. 本文：create-story-slides の型で書く（ノートは【時間】と話す・つなぎ・根拠・メモ）
- [ ] 5. 見た目：Visual pass で実画面・実データのグラフ・図・アイコンを入れる
- [ ] 6. 検査：ovs deck check / lint、推定9:00以内、全ページを目視
- [ ] 7. 仕上げ：README・ビルド・コミット。指示があれば push と PDF の共有
```

### 1. 材料

- 自分の成果がネタなら、実物から数える。例：`git log --format=%ad --date=format:%Y-%m -- <path> | sort | uniq -c`、パッケージ別のコミット数、スクリプトの行数・項目数。数えたコマンドと集計日をノートの「根拠」に残す。
- 仕様の話は公式ドキュメントを実際に開いて確かめる（記憶で書かない）。新機能や版は CHANGELOG（`gh api repos/anthropics/claude-code/contents/CHANGELOG.md`）で版と日付を確認する。
- 人や組織への言及（「中の人」など）は、公開プロフィールなどで裏づけ、ノートに出典を残す。確かめられない言い方は避ける。
- 公開してよい情報か迷うもの（住所に近い地名、社内の情報、他人の名前）は、載せる前にユーザーに確認する。

### 2. 骨組み

- 10分のLTは本編15〜17枚（表紙・自己紹介・まとめ・終幕を含む）。ノートの推定は9:00以内に収める。
- 章は4〜5個で、N01（上部の現在地）に使う。例：しくみ｜実例｜工夫｜できること｜始め方。
- 題名は表紙で2行に収める（1行に全角12〜13字が上限）。副題は1行。見出しは主張にする（自己紹介は「自己紹介」固定）。
- 結びは L12（学び3点）→ L18（「ご清聴ありがとうございました」だけ、名前・副題なし）。
- 経緯の羅列（何回変更したか、の年表）は聞き手が求めないことが多い。結果としての実例を見せることを優先する。
- 骨組みを短く示したら、ユーザーが止めない限りそのまま作る。

### 3〜4. 雛形と本文

```bash
~/.agents/skills/lt-deck/scripts/new-lt.sh <slug> "<題名>" ["<イベント名>"]
```

`deck.md`（表紙・自己紹介・終幕入り）、`README.md`、`assets/photo.jpg`、`npm run build:<slug>`、ルート README の一覧の行ができる。本編は create-story-slides の型で書く。

### 5. 見た目（Visual pass）

文字だけのページを1枚ずつ見直し、次の順で主張を支えるものを入れる（create-story-slides の design-system.md「Visual pass」）。

1. **実画面**：自分のリポジトリ、公開済みのissueやドキュメント。未ログインのブラウザ・2倍で撮る。表や一覧は画面の幅を狭め（約760px）、文字が大きく写るように切り抜く。元画像を残し、条件をREADMEに書く。
2. **端末の出力**：自作スクリプトの出力は、サンプル値の入力で実際に動かして描画する（個人のパスや金額を出さない）。
   `python3 ~/.agents/skills/lt-deck/scripts/ansi2html.py out.ansi out.html --font-size 15` で端末風HTMLにし、Playwright で `#t` を2倍で撮る。1行が長いときは `--split 2:<文字>` で2段に折り返し、22px程度で描き直す。
3. **実データのグラフ**：比較は theme の `.bars`、時系列は数値から生成したインラインSVG。強調は1系列だけ。
4. **アイコンとロゴ**：`~/.agents/skills/create-story-slides/scripts/fetch-icons.sh <assets> <名前>...`、`node ~/.agents/skills/create-story-slides/scripts/export-brand-marks.mjs <assets> <id>...`。使わなかったものは消し、版と出典をREADMEに残す。

L13（同じ位置で段を進める型）では、画像も `.detail` の中に置く（外に置くと帯の裏に隠れ、検査でも見つからない）。

### 6. 検査

```bash
cd ~/01_development/slides/repository
ovs deck check slides/<name>/deck.md --theme themes/story-slides.css --shots <scratchpadのフォルダ>
ovs deck lint slides/<name>/deck.md --minutes 10
ovs deck outline slides/<name>/deck.md --minutes 10
```

- check の error・warn は0にする。lint の warn は直すか、理由を README の「検証」に書く（例：L13の3連続は型の意図どおり、英語の原文を見せる表の本文量）。
- 縮小一覧（contact-sheet.png）で全体を見て、画像・図・グラフのページは原寸で見る。機械の検査は画像の重なりや読めない小ささを見逃す。

### 7. 仕上げ

- `npm run build:<slug>` で HTML と PDF を作り、README（構成・素材の出典・検証）を更新して slides リポジトリにコミットする。
- push はユーザーの指示があってから。Slack で共有したいと言われたら `open -R slides/<name>/deck.pdf` で Finder に出す（PDFに発表者ノートは入らない）。
- 報告には、PDFの場所、本編の枚数と推定時間、残した未定事項（日付など）、検査結果を書く。

## 既存LTの修正

既存の `slides/*-lt/` を直すときも同じ順で確かめる。数値を変えたら集計日をそろえ、README の構成表と「経緯」を更新し、作り直した画像は撮影条件を書き直す。
