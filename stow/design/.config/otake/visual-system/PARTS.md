# Parts

パーツは見た目ではなく、読者へ伝える関係で選ぶ。

| part | 伝える関係 | 主な入力 | 避ける |
|---|---|---|---|
| `cover` | 記事の中心メッセージ | 短いタイトル、補足、3語 | 本文の全要約 |
| `definition` | 用語と範囲 | 用語、定義、含む／含まない | 辞書の長文転記 |
| `before-after` | 同じ観点での変化 | 変更前、変更後、変化の理由 | 比較軸の違う対比 |
| `timeline` | 時間による変化 | 3〜4時点、出来事、判断 | 時間と無関係な列挙 |
| `architecture` | 境界、層、責務 | 3〜4層、依存方向 | 処理順との混同 |
| `sequence` | 主体間の順序 | 3主体、4前後のメッセージ | 時間方向の混在 |
| `flow` | 因果、手順、変換 | 3〜5ノード、矢印の意味 | 8ノード以上 |
| `comparison` | 選択肢の違い | 2〜4案、共通の比較軸 | 強調行と列の競合 |
| `matrix` | 2軸分類、優先順位 | 軸の両端、対象ラベル | 軸の意味が曖昧な配置 |
| `chart` | 実測値の差・推移 | 数値、単位、期間、出典 | 疑似データ、3D円 |
| `gantt` | 工程、担当、進捗、依存 | タスク、開始・終了、担当、状態 | 9タスク以上、循環依存 |
| `roadmap` | 優先順位と価値の順序 | Now / Next / Laterの成果 | 確定日程としての誤用 |
| `wbs` | 成果物と作業の分解 | 親成果物、作業パッケージ | 動詞だけの曖昧な階層 |
| `raci` | 成果物ごとの責任分担 | 成果物、役割、R/A/C/I | 1行に複数のA |
| `raid` | 不確実性と対応責任 | Risk / Assumption / Issue / Dependency | 担当・確認日のない列挙 |
| `status-board` | 週次の状況と次の行動 | 全体状況、進捗、節目、阻害要因 | 詳細タスクの詰め込み |
| `takeaway` | 結論と次の行動 | 一文の結論、行動 | 記事全体の要約 |
| `warning` | 制約、誤用、回避策 | 問題、理由、回避策 | 不安だけを煽る表現 |

## チャート

| type | 適する問い | 必須列 |
|---|---|---|
| `bar` | 項目間の大きさはどう違うか | `category,value` |
| `line` | 時間とともにどう変わるか | `series,category,value` |
| `stacked-bar` | 全体の内訳はどう違うか | `series,category,value` |
| `dot` | 小さな差を簡潔に比べたい | `category,value` |
| `slope` | 2時点でどう変わったか | `category,start,end` |
| `scatter` | 2変数に関係があるか | `label,x,y` |
| `heatmap` | 2カテゴリの組み合わせはどうか | `x,y,value` |
| `waterfall` | 増減が合計へどう効いたか | `category,value` |
| `small-multiples` | 系列ごとの形を比べたい | `series,category,value` |
| `progress` | 目標に対してどこまで進んだか | `category,value` |

棒、積み上げ、progressは原則0起点。系列は4つまで。数値を直接ラベルし、
不要な凡例を増やさない。

## PM素材

| 目的 | 推奨パーツ／チャート |
|---|---|
| 工程と依存関係 | `gantt` |
| Now / Next / Later | `roadmap` |
| 作業分解 | `wbs` |
| 責任分担 | `raci` |
| リスク・前提・課題・依存 | `raid` |
| 週次報告 | `status-board` |
| マイルストーン | `timeline` |
| ステークホルダーマップ | `matrix` |
| バーンダウン／バーンアップ | `chart` + `line` |
| リスクの確率×影響 | `matrix` |
| システム間の依存 | `architecture` |

ガント入力は`id,task,start,end,owner,status,progress,dependsOn,milestone`。
状態は`planned`、`active`、`blocked`、`done`を使う。`dependsOn`は
finish-to-start依存で、後続タスクは依存タスクの終了翌日以降に開始する。

## 記事レシピ

| recipe | sequence |
|---|---|
| `technical-explainer` | cover → definition → architecture → sequence → takeaway |
| `comparison-guide` | cover → before-after → comparison → matrix → takeaway |
| `data-story` | cover → chart → timeline → flow → takeaway |
| `retrospective` | cover → timeline → warning → before-after → takeaway |
| `project-plan` | cover → wbs → gantt → roadmap → raci → raid |
| `weekly-status` | status-board → gantt → raid → takeaway |

レシピは完成枚数のノルマではない。文章だけで十分な箇所は図にしない。

## 共通ルール

- `eyebrow`: 図の種類または章
- `title`: 主メッセージ
- `subtitle`: 一文の補足
- `source`: 出典
- `brand`: 固定署名。編集しない
- `label-*`, `body-*`, `cell-*`: briefの`content.slots`から差し替える

差し替えは`ovs render`に任せる。`data-slot`を手作業で編集しない。
