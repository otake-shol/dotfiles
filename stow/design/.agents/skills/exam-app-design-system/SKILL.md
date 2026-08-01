---
name: exam-app-design-system
description: Audit, introduce, migrate, or review the shared React Native (Expo) design system for qualification-exam apps. Use when Codex needs to apply the shindanshi-app design approach to another app, establish semantic theme tokens and NativeWind integration, organize reusable UI primitives and icons, introduce QGuide safely, create an app design profile, route existing visual assets without duplication, or verify accessibility and design-system conformance.
---

# Exam App Design System

資格試験アプリへ共通デザイン基盤を導入する。仕様や素材をこのスキルへ複製せず、
`exam-app-template`、OVS、対象アプリの3つの正本を使い分ける。

## Workflow

1. 対象リポジトリの `AGENTS.md`、`CLAUDE.md`、README、package scriptsを読む。
2. [source-routing.md](references/source-routing.md) を読み、対象アプリ、
   `exam-app-template`、OVSの所在と責務を確定する。
3. `exam-app-template/DESIGN-SYSTEM.md` と対象アプリの
   `docs/design-system.md` を読む。プロフィールが無ければテンプレートから作成する。
4. [acceptance-checklist.md](references/acceptance-checklist.md) に従って現状を監査し、
   準拠、移行中、未対応を区別する。
5. 新規導入は次の順で進める。

   1. アプリ固有プロフィール
   2. `theme.tokens.js` を唯一の正とするトークン
   3. 型付き `theme.ts` と NativeWind のCSS変数経路
   4. `components/ui` のプリミティブ
   5. アプリ固有アイコンと状態表現
   6. QGuide
   7. 画面単位の移行

6. 既存アプリは一括置換しない。機能単位で移行し、既存ユーザーの本文サイズ、
   状態の意味、操作ラベルをテストで固定する。
7. 対象リポジトリの型、Lint、関連テスト、代表画面の目視確認を行い、
   実行結果と未移行項目を報告する。

## Source rules

- 共通仕様とQGuide原画・コンポーネントは `exam-app-template` を正本にする。
- 色値、科目、画面、アイコン割当、登場箇所は対象アプリのプロフィールと実装で管理する。
- OVSは記事、スライド、OGP、SNS図解の正本にする。アプリUI部品や
  React Native用トークンの正本として使わない。
- 学習図解は対象アプリのデータ、表示制約、検証スクリプトに従う。
  OVS出力をそのままアプリへコピーしない。
- 共通仕様を各アプリへコピーして改変しない。アプリ側には固有判断だけを残す。

## Implementation guardrails

- Tailwind、Material、アイコンライブラリの既定値をブランド値として採用しない。
- `app/` と `components/` に色のHEXを直書きしない。
- 状態を色、透明度、アイコン、キャラクターのいずれか1つだけで表現しない。
- 分野色と正誤・注意・達成などの状態色を同値にしない。
- 本文の既定サイズを実測せずに変更しない。13px未満の文字を導入しない。
- QGuideを消しても情報と操作が成立するようにする。1画面1体を基本とし、
  Reduced Motionでは静止した最終状態を表示する。
- 外部画像URL、追加トラッキング、個人情報を含む発話を導入しない。
- 対象アプリの既存差分を戻さず、移行範囲外のファイルを整形しない。

## Completion report

次を簡潔に報告する。

- 参照した正本と、対象アプリに作成・変更したファイル
- 共通資産とアプリ固有資産の境界
- 監査で見つかった未移行項目
- 型、Lint、テスト、目視確認の結果
