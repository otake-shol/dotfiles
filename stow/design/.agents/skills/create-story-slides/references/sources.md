# 根拠と更新の手順

指針を更新するときに読む。スライドを作るだけなら読まなくてよい。

## 更新の手順

1. 新しい知見の一次情報（論文・公式ドキュメント・原著者の記事）を開き、主張と適用条件を確認する。
   二次情報の要約だけで規則を足さない。
2. 既存の規則との関係（補強・修正・新規・不採用）を決める。数値の目安は根拠と一緒に書き、根拠のない数値を足さない。
3. このスキルの該当する参照文書へ反映し、下の一覧に行を足す（確認日を更新する）。
   旧OVS側の転送文書には規則を追加しない。媒体共通の原則は `.agents/design/` で管理する。
4. 機械で判定できる規則はOVSの `scripts/deck.mjs`（静的）か `scripts/deck-check.mjs`（実測）に実装し、
   OVSの `test/deck.test.mjs` にテストを書く。閾値は定数に根拠のコメントを付けて定義する。
5. 過去の発表資料に `ovs deck verify` を実行し、誤検知が増えていないことを確かめる。
6. `make validate` を通してからコミットする。

## 根拠の一覧（2026-10-02 確認）

旧OVS指針から移した調査記録。移動時に外部情報を再検証したものではない。
表中のstoryは `story-modes.md`、designは `design-system.md`、marpは `marp-output.md`、
reviewは `review.md` に対応する。数値や媒体固有の条件は現在の各仕様を優先し、
この一覧の要約だけで規則を上書きしない。

| 出典 | 採用した考え方 | 反映先 |
| --- | --- | --- |
| [Alley「Checklist for Assertion–Evidence Slides」](http://www.writing.engr.psu.edu/AE_checklist.pdf)（Penn State） | 見出しは主張の文で2行まで。証拠は視覚的に示し箇条書きを避ける。リストは2〜4項目。見出し28pt・本文18〜24pt・出典12〜14pt | story、marp、`deck.mjs` |
| [Garner & Alley (2013)](https://pure.psu.edu/en/publications/how-the-design-of-presentation-slides-affects-audience-comprehens/) International Journal of Engineering Education 29(6) | 主張と証拠型のスライドで理解が深まり、誤解と認知負荷が減り、遅延テストの記憶も上回った（工学部生110名） | story |
| [Mayer (2014)「Multimedia Instruction」](https://eddl.tru.ca/wp-content/uploads/2020/01/mayer-multimedia-instruction.pdf) Handbook of Research on Educational Communications and Technology 第31章 | 一貫性（余計なものを除く）、信号化（要点と構成を示す）、空間的近接（語を図の近くに置く）、冗長性（話す文と同じ文を映さない。要所の短い語を図の近くに置けば影響は小さい）、分割、予期（先に問いを示す） | story、design |
| [Duarte「The Glance Test」](https://www.duarte.com/resources/guides-tools/the-glance-test/) | 3秒で意味が分かるか | design、review |
| [Duarte「Resonate」](https://www.duarte.com/resources/books/resonate/)・[Presentation Sparkline](https://www.duarte.com/blog/ultimate-guide-to-contrast/) | 現状と変化後の姿を往復する構成。聞き手が主人公、発表者は案内役 | story |
| [Storytelling with Data「horizontal logic」](https://www.storytellingwithdata.com/blog/2013/12/horizontal-logic) | タイトル列だけで話が通る。冒頭の要約の各項目を後続のタイトルと対応させる | story |
| [Doumont (2002)「The Three Laws of Professional Communication」](https://users.cs.utah.edu/~dejohnso/threelaws.pdf) IEEE Transactions on Professional Communication 45(4) | 聞き手に合わせる。信号対雑音比を最大化する。情報（売上15%減）ではなくメッセージ（広告を増やすべき）を伝える | story、design |
| Minto『The Pyramid Principle』（書籍） | 結論を先に置く。状況→困りごと→問い→答え（SCQA）で導入する | story |
| [前田鎌利「13＋40の法則」](https://diamond.jp/articles/-/301341)・[「キーメッセージは13文字以内」](https://diamond.jp/articles/-/79233)（ダイヤモンド・オンライン） | 一度に知覚できる文字数は9〜13字、40字なら約10秒で理解できる、4桁超の数値は丸める、社内プレゼンは5〜9枚 | story、`deck.mjs` |
| [前田鎌利 氏 直伝！ 資料作成＆プレゼンの極意](https://www.softbank.jp/business/content/blog/202401/presentation-techniques)（ソフトバンク、2024-01） | 本編5〜9枚。課題→原因→解決策→効果。接続詞でスライドをつなぐ。発表3分・議論10分・決断2分 | story |
| [矢野香「『早口』と『ゆっくり』、どちらの話し方がいい？」](https://president.jp/articles/-/19697?page=2)（PRESIDENT Online、2016） | NHKのアナウンサーがニュースを読む速さは1分300字 | story、`deck.mjs` |
| [How Jeff Bezos Turned Narrative into Amazon's Competitive Advantage](https://slab.com/blog/jeff-bezos-writing-management-strategy/)（Slab、2004-06-09のメールを引用） | 文章のメモは何が何より重要か、どう関係するかの理解を強いる | story |
| [FT Visual Vocabulary](https://github.com/Financial-Times/chart-doctor/tree/main/visual-vocabulary) | 伝えたい関係（偏差・相関・順位・分布・時間変化・大きさ・部分と全体・空間・流れ）からチャートを選ぶ | design |
| [W3C「Understanding SC 1.4.3: Contrast (Minimum)」](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)（WCAG 2.2） | 本文4.5:1。大きな文字（18pt、太字14pt）は3:1 | design、`deck-check.mjs` |
| [Chrome for Developers「Introducing four new international features in CSS」](https://developer.chrome.com/blog/css-i18n-features) | `word-break: auto-phrase` はChrome 119以降、`lang="ja"` が必要 | marp、テーマ |
| [Marp CLI README](https://github.com/marp-team/marp-cli)（v4.4.0） | `--notes`、`--pdf-notes`、`--pdf-outlines`、段階表示（`*`・`1)`）、発表者ビュー（`p`）、`--pptx-editable` の制約 | marp、review |
| [伝わるデザイン](https://tsutawarudesign.com/) | レイアウト、表とグラフ、文字組み、配色、配色のバリアフリー | design |
| [高橋メソッド](https://ja.wikipedia.org/wiki/%E9%AB%98%E6%A9%8B%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89)（Wikipedia） | 巨大な文字と最小限の言葉だけで進める。LTの選択肢 | story |
| [Zheng ほか (2025)「PPTAgent」](https://arxiv.org/abs/2501.03936) EMNLP 2025 | 生成したスライドを内容・デザイン・一貫性の3観点で評価する | review |
| [Chen ほか (2026)「X+Slides」](https://arxiv.org/abs/2606.19256) | 聞き手に必要な情報の網羅と出典に基づく正確さを見た目と分けて評価する | review |
| [Anthropic「Skill authoring best practices」](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) | 目次となる本体と1階層の参照、コピーして使うチェックリスト、検証と修正の繰り返し、決まった処理はスクリプトへ | 本指針の構成、`ovs deck` |
| Anthropic pptx スキル・OpenAI Google Slides スキル・Figma Slides スキル（各社のAI向け手順書、2026-10時点） | 代表の数枚を先に作る。修正後の新しい画像で確かめる。同じ構造の反復・何でも枠で囲む表現・飾りの足し算を避ける | design、review |
