---
name: youtube-ops
description: YouTubeチャンネルの企画、調査、構成、台本、ビジュアル指示、サムネイル、Shorts、品質確認、公開後改善を再現可能な制作ラインとして設計・運用する。YouTube動画の制作、チャンネル運営の仕組み化、動画パッケージのレビュー、長尺動画からShortsや翻訳版への展開を依頼されたときに使う。単発の映像編集だけを求める依頼には使わない。
---

# YouTube運営システム

動画を単発の原稿ではなく、検証可能な構造化データから派生するコンテンツ群として扱う。人間の経験と判断を起点にし、反復作業と機械的な検査をCodexへ寄せる。

## 運用原則

- `channel.json`をチャンネル方針、語り口、対象視聴者、デザイン制約の正とする。
- 各企画の正を`episode.json`に置く。台本、ビジュアル、長尺版、Shorts、翻訳、説明文を同じ企画データから派生させる。
- 外部検証できる主張をclaimとして分離し、分野に合う一次情報または直接観測へ結び付ける。推測、意見、観測結果を事実と混同しない。
- 自由生成より検証済みテンプレートからの選択を優先する。新しい表現は既存の型で伝わらない場合だけ追加する。
- AIレビュー後に人間の承認を挟む。最低限の承認点は企画、構成、マスター台本、サムネイル、公開とする。
- 人間の修正をログへ残す。同じ修正が続いた場合はプロンプト、テンプレート、検証規則のいずれかへ昇格させる。
- 投稿、公開予約、外部サービスへの書き込みは明示的な依頼がある場合だけ実行する。
- 参考チャンネルのブランド、キャラクター、固有表現、台本、画像を複製しない。再利用する対象を工程設計、データ契約、品質管理の考え方に限定する。

## モード判定

依頼と既存成果物から次のモードを選ぶ。複数工程を求められた場合は必要なモードを順に実行する。
コマンド中の`<skill-directory>`をこの`SKILL.md`があるディレクトリへ置き換える。

### チャンネル初期設計

チャンネルの約束、対象視聴者、テーマの柱、除外範囲、語り手、視覚規則、人間の承認点を定義する。[制作パイプライン](references/pipeline.md)と[成果物契約](references/artifact-contract.md)を読む。必要なら初期化スクリプトを使う。

```bash
node <skill-directory>/scripts/youtube_ops.mjs init-channel <channel-directory>
```

空欄を一般論で埋めず、本人の経験、調べたい理由、視聴者へ約束する価値から決める。方向が大きく分かれる未決事項だけユーザーへ確認する。

### 企画・調査・台本

[編集システム](references/editorial-system.md)を読む。価格、仕様、日付、人物、数値、引用など変化または誤認しやすい情報を調査し、分野に応じた一次資料を優先する。確認できない主張を断定文へ変換しない。

```bash
node <skill-directory>/scripts/youtube_ops.mjs init-episode <channel-directory> <slug> [YYYY-MM-DD]
```

企画の種を一度に完成台本へ変換しない。brief、research、claims、outline、scriptの順に合意と根拠を積み上げる。

### ビジュアル・パッケージ・Shorts

[編集システム](references/editorial-system.md)のビジュアル、サムネイル、Shorts節を読む。長尺版の単純な切り抜きではなく、同じclaimsから画面比率と視聴文脈に合う別構成を作る。既存のデザインシステムや`otake-visual`がある場合は新しい表現体系を重複作成せず、テンプレートIDと出力パスを`episode.json`へ記録する。

### 学習プロダクト連携

動画からアプリ、教材、問題演習へ接続する場合は[学習プロダクト連携](references/learning-product-integration.md)を読む。スキル本体へ特定分野のIDやパスを埋め込まず、`channel.json`の`integrations`と`episode.json`の`learning_target`へ分離する。

CoreQ連携では次の検査を使える。`<app-root>`は実行時に渡し、チャンネル設定へ端末固有の絶対パスを保存しない。

```bash
node <skill-directory>/scripts/learning_product.mjs inspect shindanshi-app <app-root> <concept-id>
node <skill-directory>/scripts/learning_product.mjs validate shindanshi-app <episode-directory> <app-root>
```

アプリの教材データを教育内容の正本とし、動画側は論点ID、図解ID、参照箇所のハッシュ、対象年度を保持する。問題本文、回答、検索語、個人情報を計測用パラメータへ入れない。

### 品質確認・公開判定

[成果物契約](references/artifact-contract.md)を読み、機械検査と意味検査を分ける。

```bash
node <skill-directory>/scripts/youtube_ops.mjs validate-channel <channel-directory>
node <skill-directory>/scripts/youtube_ops.mjs validate <episode-directory>
node <skill-directory>/scripts/youtube_ops.mjs validate <episode-directory> --publish
```

機械検査の成功を正確性の証明として扱わない。claimと出典の対応、説明の飛躍、観測条件、画面の可読性、タイトルと内容の一致を別途確認する。`--publish`は公開可能性を検査するだけで公開処理を行わない。

### 公開後改善

[改善ループ](references/improvement-loop.md)を読む。人間の修正、AIレビュー、公開後指標を混ぜずに記録する。単発の好みを恒久規則へ昇格させない。

## 完了条件

- 初期設計: `channel.json`の必須項目と承認点が定義され、機械検査が成功している。
- 企画: 視聴者の課題、動画の約束、独自の切り口、扱わない範囲が明確になっている。
- 台本: 検証可能な主張が出典または観測へ接続され、各セリフの話者、目的、ビジュアルが追跡できる。
- パッケージ: タイトルとサムネイルが内容を正確に表し、Shortsが本編への入口として独立して理解できる。
- 公開判定: 未解決の重大指摘がなく、全人間ゲートが承認済みになっている。
- 改善: 修正理由と指標から次回に変える仕組みが1つ以上特定されている。
- 学習プロダクト連携: 教材ID、図解ID、Deep Link、参照ハッシュの整合性が検査でき、動画から演習までのCTAが1つに定まっている。

設計の由来を確認するときだけ[公開事例からの抽出](references/public-case-study.md)を読む。
