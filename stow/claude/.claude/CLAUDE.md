# dotfiles プロジェクト設定

グローバル設定を参照:

@~/.claude/CLAUDE.md
@~/.claude/environment.md

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

## Claude Code 4.7 運用原則（委譲・自律・検証）

旧前提（逐次指示・常時監視・手動運用）→ 新前提（**委譲・自律実行・検証付き運用**）。
4.7 以降は「細かく操作する」より「任せて、検証する」方が品質が上がる。

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
