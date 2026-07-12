# グローバル設定（全プロジェクト共通）

詳細設定を参照:

@~/.claude/environment.md
@~/.claude/engineering-quality.md

---

## 私について

- 本業: リクルートでHR領域のプロダクト開発を担当するエンジニア
  （現在の主担当は r-agent.com のテクニカルSEO実装。担当はSEOに限らずHR領域全般）
  開発プロジェクトのリーダー / プロジェクトマネージャーも務める
- 副業: おたけ屋（個人事業主）
- 技術: TypeScript / React / Next.js が中心、API開発で Java も使う
- 処理速度が速く要点を先に知りたいタイプ。前置きや過剰な気遣いは省いてよい
- 応答方針: 結論ファーストで簡潔に。複数質問は全体像→一問一答。選択肢はおすすめ＋トレードオフを併記

---

## 運用原則（委譲・自律・検証）— モデル非依存

旧前提（逐次指示・常時監視・手動運用）→ 新前提（**委譲・自律実行・検証付き運用**）。
「細かく操作する」より「任せて、検証する」方が品質が上がる。どのモデルでも同じ。

### 6つのやめるべきこと

1. **逐次指示をやめる** → Goal / Constraints / Acceptance Criteria を最初にまとめて渡し、途中介入を減らす
2. **Effort=max の常用をやめる** → 基本は **xhigh**、max は最難関タスクだけに限定（max は overthinking で遅く・不安定になる場合あり）
3. **`--dangerously-skip-permissions` の常用をやめる** → Auto Mode や `/fewer-permission-prompts` で安全に権限確認を減らす
4. **長時間の見守り運用をやめる** → `/focus` で結果中心に確認、Recaps で復帰時に状況把握
5. **Subagent の乱用をやめる** → 複数ファイル並列や独立タスク以外は Claude 自身の判断に任せる（毎回明示的に呼ばない）
6. **検証なしで任せるのをやめる** → tests / screenshots / expected outputs を渡して自己検証させる

### 結論

「適切に委譲できること」と「自動で検証できること」が品質を左右する。
運用キーワードは『**委譲・自律・検証**』。

> 詳細・根拠・例外: Obsidian Vault `30_resources/evergreen/Claude Code 4.7は委譲と検証で品質が上がる.md`
> 出典: 理久さん（@rik423__ai）投稿 2026-04 頃 / Qiita 記事（ot12）ベース

---

## モデル・effort の使い分け（従量課金を意識）

| タスク | モデル | effort |
|--------|--------|--------|
| 単純作業・検索・分類・要約 | haiku | 非対応（固定 thinking budget のみ） |
| 標準的なコーディング | sonnet | high〜xhigh |
| 複雑な設計・長時間エージェント・調査 | opus / fable | xhigh |
| 最難関のみ | opus / fable | max（常用しない） |

- 切替は `/model <alias>` と `/effort <level>`。未対応の effort 値はそのモデルの上限に自動 fallback（例: Opus 4.6 で xhigh → high）
- **thinking は output トークンとして課金**される。コスト優先のセッションは `/effort low〜medium` に落とす
- **fast mode（`/fast`）は Opus のみ・料金2倍**。ライブデバッグ等の対話作業向け。バッチ・長時間タスクでは使わない。セッション途中で ON にすると履歴分も fast 料金になるため、使うなら開始時に
- **prompt cache は 5分 TTL**。5分以上放置して再開すると全コンテキスト再読み込み（cache write は 1.25x、cache read は 0.1x）。長い CLAUDE.md や巨大コンテキストほど再開コストが増える
- サブエージェントは frontmatter `model: haiku` で軽量化できる。読み取り・検証・分類系は haiku で十分（`~/.claude/agents/explore-lite` を活用）
- 料金の目安（input/output per MTok）: Opus 4.8 $5/$25、Sonnet 5 $3/$15、Haiku 4.5 $1/$5
