---
name: proposal-onepager
description: 顧客に渡す A4 1 枚の提案資料（業務診断・見積もり前の提案・サービス案内など）を、Markdown を正本にして PDF で作る・直す・レビューする。配色と書体は create-story-slides の Standard を使い、A4 印刷物の差分だけをこのスキルで持つ。「提案資料を1枚で作って」「お客さんに渡すA4の資料」「提案書のPDFを直して」「この1枚資料をデザインレビューして」などで使う。スライド（投影・登壇）は create-story-slides、編集可能な共同文書は Docs を使う。
---

# Proposal One-pager

顧客に手渡す・メールで送る A4 1 枚の提案資料を、Markdown から PDF にする。
正本は Markdown。PDF や Claude Docs を直接直さない（直しても正本に戻らず、内容が食い違う）。

## 参照するもの

作る前に読む:

- `references/print-profile.md`：A4 印刷物としての差分（文字サイズ・余白・色の使いどころ）
- `references/components.md`：本文で使える部品と書き方
- 配色・書体の正本：create-story-slides の `references/design-system.md`（Standard プロファイル）
- 共通の判断と確認手順：`../../design/design-intent.md`

レビューの前に読む: `references/review-checklist.md`

## 手順

1. **相手と場面を決める**：誰が、どこで（手渡し・メール・社内の稟議）、何を判断するか。制作メモに残す（資料の本文には書かない）。
2. **正本の Markdown を書く**：既存の提案を複製するか、`assets/example.md` から始める。顧客の資料はプロジェクト側（例：Obsidian Vault の案件フォルダ）に置き、このスキルには置かない。
3. **PDF を作る**：

   ```bash
   assets/build.sh <入力.md> <出力.pdf>
   ```

   - 必要なもの：pandoc、Google Chrome、pdfinfo（任意：2 ページになると警告）
   - PDF などのバイナリはテキストの管理場所に置かない（Vault なら iCloud 側の案件フォルダ）
4. **画像にして目で確認する**：`pdftoppm -r 110 -png <pdf> <prefix>` で 1 ページに収まっているか、折り返し・欠け・重なりがないかを見る。書体の埋め込みは `pdffonts <pdf>` で確かめる。
5. **レビューする**：`references/review-checklist.md` を上から当てる。指摘は重要な順に並べ、決める必要があるものは一問ずつ確認する。
6. **1 ページに戻す**：溢れたら、まず繰り返しと不要な注記を削る。次に余白、最後に文字サイズ（下限は print-profile の値）。

## してはいけないこと

- 顧客名・金額・紹介者名などをこのスキルのファイル（公開リポジトリ）に書かない
- 取り消し線と「通常価格」を、中身が違うものや販売実績のない価格に使わない（review-checklist の 1）
- PDF を直接編集しない。直すのは常に Markdown
