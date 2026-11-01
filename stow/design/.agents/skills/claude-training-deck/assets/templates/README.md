# {{TITLE_PLAIN}}

〈1〜2文の概要〉。claude-training-deck スキルで作成した{{MINUTES}}分のハンズオン研修キット。

自己紹介: 〈判定（ルール: 理由）〉｜出典: 〈〉

## 研修の設計

- 対象・端末・開催形態：〈〉
- 題材：〈入門／業務活用／Claude Code入門〉
- 時間配分：〈章ごとの分数〉。演習は計〈〉分。
- テーマ：story-slides-warm（Claudeのロゴと公式色は使わない）。章の現在地（N01）：〈章〉。
- 未定：〈開催日など〉

| ファイル | 中身 |
| --- | --- |
| `training.md` / `training.pdf` / `training.html` | 研修スライド〈N〉枚。動画はHTML版で再生する |
| `worksheet.md` / `worksheet.pdf` | 受講者用ワークシート（読む資料） |
| `facilitator-guide.md` | 講師ガイド |

## 構成

| 枚 | 見出し | 型 | Phase |
| --- | --- | --- | --- |

## 素材の出典

- 〈実画面・録画・Claude Code の画面：撮影日・プラン・条件・元の画面の場所〉
- アイコン：lucide-static 〈版〉（ISC）を `ICON_COLOR=#B0502C` で取得。〈使った名前と場所〉
- 事実の確認（〈YYYY-MM-DD〉）：
  - 〈リンク〉：〈要点〉
  - 未確認：〈〉

## 編集と再生成

```bash
npm run build:{{SLUG}}
ovs deck check {{DIR}}/training.md --theme themes/story-slides-warm.css
ovs deck check {{DIR}}/worksheet.md --theme themes/story-slides-warm.css --mode read
ovs deck lint {{DIR}}/training.md
```

## 検証

〈日付、検査結果、目視したページ、意図的に残した指摘と理由〉
