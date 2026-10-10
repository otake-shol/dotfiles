# 学習プロダクト連携

## 目的

動画を理解の入口、学習プロダクトを演習と定着の場として接続する。動画へ教材本文を複製せず、教材IDと参照ハッシュで同じ論点を追跡する。

## 責務分離

| 正本 | 管理対象 |
|---|---|
| 学習プロダクト | 教材本文、問題、図解、権限、学習履歴 |
| `channel.json` | 接続先、アダプター、許可する匿名計測軸 |
| `episode.json` | 動画が扱う教材ID、対象年度、着地先、CTA |
| OVSまたはチャンネルテンプレート | 外部動画とSNS用の図解表現 |

アプリUI用素材と外部動画用素材を同じファイルとして二重管理しない。教材図解を動画で使う場合も元IDを記録し、動画向けのトリミングや注釈は派生物として管理する。

## `channel.json`契約

`integrations`へ`kind: "learning_product"`の接続先を追加する。

```json
{
  "id": "learning-product",
  "kind": "learning_product",
  "adapter": "product-adapter",
  "content_authority": "product-repository",
  "character_id": "guide-character",
  "app_scheme": "product",
  "landing_base_url": "https://example.com/learn",
  "allowed_analytics_dimensions": ["source", "subject", "category"],
  "prohibited_analytics_dimensions": ["question_id", "answer", "search_term", "route_params", "personal_data"]
}
```

教材リポジトリの絶対パスは保存しない。検査時にCLI引数として渡す。

## `episode.json`契約

```json
{
  "learning_target": {
    "integration_id": "learning-product",
    "subject_id": "subject",
    "concept_ids": ["concept-id"],
    "visual_asset_ids": ["visual-id"],
    "validity": {
      "mode": "evergreen",
      "exam_year": null,
      "review_by": null
    },
    "entry": {
      "landing_path": "/concept-id",
      "app_deep_link": "product://learn?focus=concept-id"
    },
    "practice": {
      "mode": "category",
      "cta": "アプリでこの分野を解く"
    },
    "analytics": {
      "source": "youtube",
      "dimensions": ["source", "subject", "category"]
    }
  }
}
```

制度、統計、法改正など更新が必要な題材は`validity.mode`を`time_sensitive`とし、`exam_year`と`review_by`を必須にする。

## ローカルsource契約

```json
{
  "id": "src-concept",
  "title": "教材の論点データ",
  "kind": "local",
  "publisher": "学習プロダクト",
  "path": "path/from/repository-root",
  "locator": "collection[id=concept-id]",
  "revision": "sha256:...",
  "accessed_at": "YYYY-MM-DD",
  "notes": "動画で参照する範囲"
}
```

`revision`はファイル全体ではなく参照した論点ブロックのハッシュを推奨する。無関係な教材更新による失効を避けながら、動画内容の陳腐化を検知できる。

## CoreQアダプター

`shindanshi-app`アダプターは次を検査する。

- `constants/cheatsheet-data.ts`に論点IDが存在する
- 論点の科目が`subject_id`と一致する
- 論点が参照する`figureId`と`visual_asset_ids`が一致する
- SVGファイルと図解registryの両方に図解IDが存在する
- ローカルsourceの参照ハッシュが現在の論点ブロックと一致する
- Deep Linkのscheme、科目、focusが企画データと一致する
- `character_id`がキューを参照し、原画のパスとハッシュが現在のアプリ資産と一致する
- キューが1画面1体で問題文、公式、解説、学習図解から除外されている

キューは唯一のキャラクター兼学習ナビとして動画全体を声で案内する。画面への登場は導入、区切り、終了時の次行動案内に限定する。講師や採点者として扱わず、問題文、公式、解説、学習図解へ重ねない。

## MVPゲート

1. 1論点1本へ限定する
2. 動画からアプリへの一方向導線を作る
3. 論点ID、図解ID、参照ハッシュ、Deep Linkを機械検査する
4. 科目・カテゴリ単位の匿名指標だけを記録する
5. 3本の検証前にアプリ内動画、双方向導線、自動公開を追加しない
