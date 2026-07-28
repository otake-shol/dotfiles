---
description: 記事からOVS図解・チャート・媒体別画像を生成
allowed-tools: Read, Write, Glob, Bash(ovs *)
argument-hint: "<article.md | brief.json | data.csv>"
---

# /visual - Otake Visual System

Otake Visual SystemのJSON briefとCLIだけを使い、図解・SVG・PNG・altを生成する。
生成済みSVGは直接編集しない。

## 入力別フロー

### Markdown記事

1. `ovs suggest <article.md>`で図の候補と記事レシピを取得する
2. 理解を明確にする図だけを選び、1図1メッセージに絞る
3. `~/.config/otake/visual-system/templates/brief.json`からbriefを作る
4. `ovs render <brief.json> --out <assets-dir>`を実行する
5. `ovs lint <assets-dir>`と`ovs preview`で確認する

### JSON brief

`ovs render` → `ovs lint` → `ovs preview`の順に実行する。
同名の生成物がある場合は対象を確認し、更新が依頼範囲内のときだけ`--force`を付ける。

### CSV / JSONデータ

タイトル、単位、期間、出典、altを確認してから`ovs chart`を実行する。
装飾用の疑似データは作らない。

### プロジェクト計画

`ovs list pm`で用途を確認する。ガントは
`id,task,start,end,owner,status,progress,dependsOn,milestone`列を持つ
CSV/JSONから`ovs gantt`で生成する。1枚8タスクまでとし、超える場合は
フェーズで分割する。WBS、RACI、RAID、週次ステータスは専用パーツを使う。

## パーツ選択

- 用語: `definition`
- 変化: `before-after`
- 経緯・計画: `timeline`
- 境界・責務: `architecture`
- 主体間の順序: `sequence`
- 因果・手順: `flow`
- 選定: `comparison` / `matrix`
- 実測値: `chart`
- 工程・担当・依存: `gantt`
- 優先順位: `roadmap`
- 作業分解: `wbs`
- 責任分担: `raci`
- リスク・前提・課題・依存: `raid`
- 週次報告: `status-board`
- 結論・注意: `takeaway` / `warning`

## 完了報告

採用したレシピ、生成ファイル、出典の状態、lint結果を短く報告する。
