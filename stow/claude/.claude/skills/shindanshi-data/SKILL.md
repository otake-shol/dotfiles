---
name: shindanshi-data
description: Use when the user wants to register wrong exam answers or study notes for the 中小企業診断士試験. Parses natural language like "経済学 R5 第3問 ア→ウ メモ" into structured data and inserts it into Supabase via CLI script.
---

# 診断士データ登録スキル

中小企業診断士試験の誤答ストックや論点メモを自然言語から登録する。

## 科目名マッピング

| 日本語（部分一致可） | subject_id |
|---------------------|------------|
| 経済学、経済 | economics |
| 財務会計、財務、会計 | accounting |
| 企業経営、経営理論 | management |
| 運営管理、運営 | operations |
| 経営法務、法務 | law |
| 情報システム、情報、IT | it |
| 中小企業、中小 | sme |

## 年度変換ルール

- `R5` / `令和5年` / `令和5` → **2023**（令和 + 2018 = 西暦）
- `R6` → **2024**、`R4` → **2022** など
- 西暦で書かれた場合はそのまま使う

## データ型

### wrong_answers（誤答ストック）

```json
{
  "table": "wrong_answers",
  "subject_id": "economics",
  "year": 2023,
  "question_number": 3,
  "my_answer": "ア",
  "correct_answer": "ウ",
  "memo": "比較優位の計算ミス"
}
```

### key_notes（論点メモ）

```json
{
  "table": "key_notes",
  "subject_id": "law",
  "title": "会社法の取締役の責任",
  "content": "善管注意義務と忠実義務の違いを整理"
}
```

## 自然言語パースルール

### 誤答パターン

`[科目名] [年度] [問番号] [自分の回答]→[正解] [メモ(任意)]`

例:
- 「経済学 R5 第3問 ア→ウ 比較優位の計算ミス」
- 「財務会計 R4 問12 イ→エ」
- 「運営管理 令和6年 第25問 ウ→ア JIT生産方式の特徴」

### メモパターン

`[科目名]メモ: [タイトル] - [内容]` または `[科目名] メモ [タイトル] [内容]`

例:
- 「経営法務メモ: 会社法の取締役の責任 - 善管注意義務と忠実義務の違いを整理」
- 「経済学 メモ IS-LM分析 利子率と国民所得の均衡条件」

## 実行方法

shindanshi-web ディレクトリで `.env.local` を読み込みつつスクリプトを実行する:

```bash
cd /Users/otkshol/01_devlopment/shindanshi-web && echo '<JSON>' | node --env-file=.env.local scripts/add-data.mjs
```

## 実行フロー

1. ユーザーの自然言語入力を上記ルールでパースして JSON を構築
2. パース結果をユーザーに確認表示（「この内容で登録しますか？」）
3. 承認後、Bash で上記コマンドを実行
4. 成功なら登録 ID を表示、失敗ならエラーメッセージを表示

## 複数件登録

ユーザーが複数のデータをまとめて指示した場合は、1件ずつ順番に登録する。
