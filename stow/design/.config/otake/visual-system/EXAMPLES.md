# Examples

生成済みサンプルは文章と値がダミー。公開時は実際の内容、データ、出典へ差し替える。

## 記事構成

| Cover | Definition | Before / After |
|---|---|---|
| ![Cover](./generated/templates/cover.svg) | ![Definition](./generated/templates/definition.svg) | ![Before After](./generated/templates/before-after.svg) |

| Timeline | Architecture | Sequence |
|---|---|---|
| ![Timeline](./generated/templates/timeline.svg) | ![Architecture](./generated/templates/architecture.svg) | ![Sequence](./generated/templates/sequence.svg) |

## 関係と判断

| Flow | Comparison | Matrix |
|---|---|---|
| ![Flow](./generated/templates/flow.svg) | ![Comparison](./generated/templates/comparison.svg) | ![Matrix](./generated/templates/matrix.svg) |

## データと強調

| Chart | Takeaway | Warning |
|---|---|---|
| ![Chart](./generated/templates/chart.svg) | ![Takeaway](./generated/templates/takeaway.svg) | ![Warning](./generated/templates/warning.svg) |

## プロジェクトマネジメント

| Gantt | Roadmap | WBS |
|---|---|---|
| ![Gantt](./generated/templates/gantt.svg) | ![Roadmap](./generated/templates/roadmap.svg) | ![WBS](./generated/templates/wbs.svg) |

| RACI | RAID | Weekly Status |
|---|---|---|
| ![RACI](./generated/templates/raci.svg) | ![RAID](./generated/templates/raid.svg) | ![Weekly Status](./generated/templates/status-board.svg) |

## ブラウザで一覧

```bash
ovs preview generated/templates --out generated/gallery.html --force
open generated/gallery.html
```

チャート入力例:

- [`examples/chart.brief.json`](./examples/chart.brief.json)
- [`examples/data/bar.csv`](./examples/data/bar.csv)
- [`examples/data/multi-series.csv`](./examples/data/multi-series.csv)
- [`examples/data/scatter.csv`](./examples/data/scatter.csv)
- [`examples/gantt.brief.json`](./examples/gantt.brief.json)
- [`examples/data/gantt.csv`](./examples/data/gantt.csv)

記事提案例は[`examples/article.md`](./examples/article.md)、Marpテーマ例は
[`examples/slide.md`](./examples/slide.md)。

## レビュー観点

- 18種類を並べても同じ作者の図に見えるか
- 鍵盤マーカーが主張しすぎていないか
- 320px幅でも見出しと主要値が読めるか
- 意味色の役割が図をまたいで変わっていないか
- 色を外しても線、位置、ラベルで関係を追えるか
- `shindanshi-app`と`my-portfolio`の延長に見えつつ、どちらかのコピーになっていないか
