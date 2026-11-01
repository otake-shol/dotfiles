---
name: claude-training-deck
description: Claude（claude.ai・スマホアプリ・Claude Code）の使い方を教える研修資料一式を、暖色テーマ・実画面・演習・講師ガイド・ワークシートつきで再現できる形で作る。「Claudeの研修資料を作って」「Claude入門のハンズオン」「クライアント向けのClaude研修」「Claudeの使い方をLTで」「研修キットのクライアント版」などで使う。既存のClaude研修キットの改訂、事実の確認し直し、画面の撮り直しにも使う。
---

# Claude Training Deck

Claudeの使い方を教える研修（ハンズオン）と、そこから切り出すLTを、毎回同じ品質で作るための段取り。
スライドの書き方・型・検査は create-story-slides に従う（作成前に必ず読み込む）。10分LTだけを作るときの段取りは lt-deck に従う。
このスキルは、Claudeを題材にしたときに固定する決まり（構成・演習・見た目・撮影・事実の確認・付属物）を持つ。

## 共通スキルとの優先順位

ユーザーの明示指定、編集対象の既存キット、本スキルの既定値、lt-deck の既定値（LTを作る場合）、create-story-slides の既定値の順に適用する。
自己紹介の要否と公開範囲、根拠、可読性の判定は create-story-slides に従う。

## 参照実装

`slides/2026-claude-first-step-lt/`（slides リポジトリ）が最初のキット。非エンジニア向けの入門で、次のファイルからなる。

| ファイル | 中身 |
| --- | --- |
| `deck.md` | 10分LT（17枚）。研修から演習と章扉を抜いた形 |
| `training.md` | 60分ハンズオン（33枚）。5章・演習6つ・実画面・デモ動画 |
| `worksheet.md` | 受講者用ワークシート（2ページ・読む資料） |
| `facilitator-guide.md` | 講師ガイド（開催前の確認・事前案内・時間割・演習メモ・つまずき・差し替え） |
| `README.md` | 構成表・素材の出典と撮影条件・確かめた事実・検証 |

迷ったら参照実装の同じ箇所を開き、書き方をそろえる。

## 前提（この環境の決まり）

- 置き場所：開催先を問わない汎用キットは slides リポジトリ（既定 `~/01_development/slides/repository`、`SLIDES_REPO` で変更可）の `slides/<年>-<slug>/`。
- クライアント別の版（開催先名・AI利用ルール）、見積もり・名簿・アンケートなどの運営情報は slides に置かない。研修専用の非公開リポジトリに置く。まだ無ければ、作る前にユーザーに確認する。
- テーマ：`themes/story-slides-warm.css`（story-slides の配色だけを暖色にした派生テーマ）。`@import` で継承するので、marp には `--theme-set themes --theme themes/story-slides-warm.css` を渡す。
- ロゴと公式色：Claude・Anthropicのロゴと公式色は使わない。理由と例外は [visual.md](references/visual.md)。
- push と Slack への共有は、ユーザーの指示があってから行う。

## 進め方

次のチェックリストを回答に写し、進めながら更新する。

```text
Claude研修:
- [ ] 1. 依頼：対象・時間・端末・開催形態・題材を決める
- [ ] 2. 事実：変わりやすい事実を公式ページで確かめ、確認日を残す
- [ ] 3. 骨組み：章・時間配分・演習・注意点の章を決め、短く示す
- [ ] 4. 雛形：new-claude-training.sh で作る（既存キットの複製は --from）
- [ ] 5. 本文と演習：create-story-slides の型で書く
- [ ] 6. 実画面と録画：capture.md の手順で撮る
- [ ] 7. 見た目：暖色テーマ・アイコン・Visual pass
- [ ] 8. 付属物：講師ガイド・ワークシート・README
- [ ] 9. 検査：ovs deck check / lint、全ページを目視
- [ ] 10. 仕上げ：ビルド・コミット。指示があれば push
```

### 1. 依頼

次の5つを決める。分からない項目は既定値で進め、結論が変わる項目だけを1つずつ聞く。

| 項目 | 既定値 | 変わるもの |
| --- | --- | --- |
| 対象 | 非エンジニア中心 | 用語・Claude Codeの扱い・演習の題材 |
| 時間 | 60分 | 章の数・演習の数（[structure.md](references/structure.md)） |
| 端末 | PC推奨、スマホでも参加可 | 演習ごとのスマホの代わり |
| 開催形態 | ミートアップ | 自己紹介・表紙の副題・AI利用ルールの1枚・置き場所 |
| 題材 | 入門（はじめて触る人） | 章立て（入門・業務活用・Claude Code入門） |

### 2. 事実

[facts.md](references/facts.md) の項目を公式ページで実際に開いて確かめる。記憶や過去のキットの記述で書かない。
確かめた日と根拠の原文を発表者ノートの「根拠:」とREADMEに残す。確かめられない項目は「未確認」として講師ガイドの開催前の確認に入れる。

### 3. 骨組み

[structure.md](references/structure.md) の時間配分・章・スライドの型から選ぶ。
演習を全体の半分以上にし、注意点の章（下書きとして確かめる・入れていい情報・学習の設定）は題材にかかわらず必ず入れる。
骨組みを短く示したら、ユーザーが止めない限りそのまま作る。

### 4. 雛形

```bash
# 新しい題材のキット（研修・ワークシート・講師ガイド・README）
~/.agents/skills/claude-training-deck/scripts/new-claude-training.sh <slug> "<題名>" [--minutes 60] [--subtitle "<副題>"]
# 既存キットの複製（クライアント版・改訂版の出発点）
~/.agents/skills/claude-training-deck/scripts/new-claude-training.sh <slug> "<題名>" --from slides/2026-claude-first-step-lt
```

package.json の `build:<slug>`（HTML・PDF・ワークシート）、ルート README の一覧の行、暖色のアイコン一式ができる。
自己紹介は雛形では空欄にしてある。create-story-slides の自己紹介の判定を行い、full なら登壇者プロフィール（lt-deck と同じ非公開のプロフィールと写真）から埋めて `assets/photo.jpg` を置く。compact / none なら L17 を消す。公開リポジトリに個人情報を書かない。
雛形のままでは `〈〉` の placeholder と写真の broken-image が検査の error になる。埋め終わったら0になる。

### 5. 本文と演習

- 演習スライドは [structure.md](references/structure.md) の「演習の型」を使う。1枚に目安の分数・手順3つ・送る文の例・成功の基準を置く。
- 送る文の例は、受講者がそのまま打てる日本語の一文にする。個人情報や社外秘を使わない題材にする。
- 実際の返事を見せる場合は実画面を使う。返事を作り話で見せる場合は「返事のイメージ」と明記し、README に「教材用の例」と書く。
- 撮影条件（いつ・どのプランで撮ったか）はスライドに表示しない。発表者ノートと README に書く。公式ヘルプなどの出典リンクはフッターに表示する。

### 6. 実画面と録画

[capture.md](references/capture.md) の手順で撮る。Web版はシークレットチャット、Claude Codeは個人の設定を読み込まない起動、スマホはユーザーに撮影を頼む。
撮った画面に履歴・アカウント名・メモリ・個人のパスが写っていないかを1枚ずつ確かめ、写った確認用の画像は削除する。

### 7. 見た目

[visual.md](references/visual.md) の配色の役割・アイコンの決まりに従い、create-story-slides の Visual pass を全ページで行う。

### 8. 付属物

- 講師ガイド：雛形の見出しを埋める。開催前の確認には、未確認の事実・画面が変わりやすいページ番号・開催地に合わせる箇所を入れる。
- ワークシート：受講者が持ち帰る1〜2ページ。頼み方の型・演習の一覧・困ったとき・入れる前の確認。`--mode read` で検査する。
- README：構成表、研修版の設計、素材の出典と撮影条件、確かめた事実（URLと確認日）、検証。

### 9. 検査

```bash
cd ~/01_development/slides/repository
ovs deck check slides/<name>/training.md --theme themes/story-slides-warm.css --shots <scratchpadのフォルダ>
ovs deck check slides/<name>/worksheet.md --theme themes/story-slides-warm.css --mode read
ovs deck lint slides/<name>/training.md
```

- check の error・warn は0にする。lint の error は日付の未定（`〈YYYY-MM-DD〉`）だけを許す。アイコンにも内容を説明する alt を付ける（空の alt は error）。
- 縮小一覧で全体を見て、実画面・図・アイコンのページは原寸で見る。動画のページは検査で空白に見えるので、PDFで静止画が出ることを確かめる。

### 10. 仕上げ

- `npm run build:<slug>` で HTML・PDF・ワークシートを作り、slides リポジトリにコミットする。
- 報告には、PDFとHTMLの場所、枚数と想定時間、未確認の事実、残した未定事項、検査結果を書く。実際の所要時間を検証したとは扱わない。

## 既存キットの改訂

- 開催のたびに [facts.md](references/facts.md) を見直し、変わった事実はスライド・講師ガイド・README・ワークシートを同時に直す。
- 画面が変わったら同じ条件で撮り直し、README の撮影条件と日付を書き換える。
- 研修を直したら、LT（`deck.md`）の同じページも直す。両方の枚数と構成表をそろえる。
