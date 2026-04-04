---
marp: true
paginate: true
size: 16:9
theme: catppuccin-latte
---

<!-- _class: lead -->

# 2026年度 上期 開発チーム計画
## プロダクト開発部 — 2026.04 - 2026.09

---

<!-- _class: lead -->

# ビジョン・目標

**「開発速度2倍、障害ゼロ」を実現する基盤を作る**

顧客価値を最速で届けるために、
デプロイ頻度とシステム信頼性の両立を目指す。

---

<!-- _class: metric -->

# 前期振り返り・KPI

<div class="cards">
  <div class="card">
    <div class="value">週5回</div>
    <div class="label">デプロイ頻度</div>
    <div class="change">週2 → 週5 ✅</div>
  </div>
  <div class="card">
    <div class="value">72%</div>
    <div class="label">テストカバレッジ</div>
    <div class="change">45% → 72% ✅</div>
  </div>
  <div class="card">
    <div class="value">1.5h</div>
    <div class="label">MTTR</div>
    <div class="change">4h → 1.5h ✅</div>
  </div>
</div>

**課題**: リリース障害 月3件（目標1件）/ 技術負債返済 60% / オンボーディング 3週間

---

# 重点テーマ

今期は **3つのテーマ** に集中する。

1. **品質ゲート強化** — リリース起因障害を月1件以下に
2. **開発者体験(DX)向上** — CI/CD高速化、ローカル環境改善
3. **チームスケール** — 新メンバー3名のオンボーディング最適化

`①` 品質ゲート強化　`②` DX向上　`③` チームスケール

---

<!-- _class: lead -->

# 実行計画
## How — どう実現するか

---

<!-- _class: columns -->

# ロードマップ

**Q1（4月〜6月）**
- `①` E2Eテスト基盤構築
- `②` CI パイプライン刷新
- `③` 新メンバー受け入れ準備

**Q2（7月〜9月）**
- `①` カナリアリリース導入
- `②` 監視ダッシュボード刷新
- `①②` 技術負債スプリント（2週間）

---

<!-- _class: org-chart -->

# 体制・リソース

<div class="tree">
  <div class="level"><div class="node head">EM 1名</div></div>
  <div class="connector"></div>
  <div class="level">
    <div class="node head">TechLead 1名</div>
    <div class="node">QA 1名</div>
  </div>
  <div class="connector"></div>
  <div class="level">
    <div class="node">Sr.Eng 2名</div>
    <div class="node">Eng 3名</div>
  </div>
</div>

SREチーム週次連携 / セキュリティレビュー月1回

---

# 運営リズム

| サイクル | 内容 | 頻度 |
|---------|------|------|
| デイリースタンダップ | 進捗・ブロッカー共有 | 毎日 15分 |
| スプリントプランニング | 2週間の作業計画 | 隔週 月曜 |
| スプリントレトロ | 振り返り・改善アクション | 隔週 金曜 |
| 1on1 | EM ↔ メンバー | 隔週 30分 |
| テックレビュー会 | 設計・コードレビュー | 週1回 |
| 月次KPIレビュー | メトリクス確認・軌道修正 | 月末 |

---

# リスク・課題

| リスク | 影響度 | 対策 |
|--------|--------|------|
| 新メンバーの立ち上がり遅延 | 高 | ペアプロ必須化 + メンター制度 |
| レガシーAPI移行の複雑さ | 中 | 段階的移行 + Feature Flag |
| SREチームのリソース不足 | 中 | セルフサービス監視ツール導入 |
| 採用計画の遅れ | 低 | 既存メンバーのスキルアップで補完 |

---

<!-- _class: timeline -->

# マイルストーン

<div class="line"></div>
<div class="steps">
  <div class="step">
    <div class="date">4月末</div>
    <div class="label">E2Eテスト基盤MVP</div>
    <div class="detail">主要フロー10件の自動テスト</div>
  </div>
  <div class="step">
    <div class="date">5月末</div>
    <div class="label">CI刷新完了</div>
    <div class="detail">ビルド時間50%短縮</div>
  </div>
  <div class="step">
    <div class="date">6月末</div>
    <div class="label">中間レビュー</div>
    <div class="detail">KPI中間評価</div>
  </div>
  <div class="step">
    <div class="date">7月末</div>
    <div class="label">カナリアリリース</div>
    <div class="detail">段階デプロイ可能に</div>
  </div>
  <div class="step">
    <div class="date">9月末</div>
    <div class="label">期末レビュー</div>
    <div class="detail">全KPI達成度評価</div>
  </div>
</div>

---

# OKR

**Objective: 顧客に最速で安全に価値を届ける**

| Key Result | 現状 | 目標 |
|------------|------|------|
| デプロイ頻度 | 週5回 | 日次（週10回以上） |
| リリース起因障害 | 月3件 | 月1件以下 |
| MTTR | 1.5時間 | 30分以内 |
| テストカバレッジ | 72% | 85% |
| オンボーディング期間 | 3週間 | 2週間 |

---

<!-- _class: lead -->

# チームとして
## Who we are — 私たちの在り方

---

<!-- _class: lead -->

# 大切にしたいチーム文化

**"速さ"より"正しさ"、"正しさ"より"学び"**

🔄 **失敗から学ぶ** — ポストモーテムは blame-free で
🤝 **助けを求める** — 「わからない」は強さ
📐 **小さく試す** — 完璧を待たず、仮説を検証する
🔍 **透明性** — 情報は隠さず、全員がアクセスできる状態に

---

<!-- _class: invert -->

# Next Action

1. **今週**: チーム計画の共有・フィードバック収集
2. **来週**: Q1スプリント0 プランニング
3. **4月1日**: 新メンバー受け入れ開始

開発速度2倍、障害ゼロ — ここから始めよう。
