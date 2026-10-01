---
description: OVSテーマのMarkdown（Marp）スライドを構成・生成・検証する。LT・登壇・提案・計画・報告・振り返りの資料作成、既存スライドの改善やレビュー、発表時間の見積もりに使う
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(marp *), Bash(ovs *), Bash(node *), Bash(mkdir *), Bash(open *)
---

# /slides - Markdownスライド制作

Codexの `source-command-slides` と同じ共通指針を使う。
最初に `~/.agents/skills/otake-visual/references/slides.md` を全文読み、そこに書かれた工程と参照先に従う。
参照先（`slides-*.md`）は同じディレクトリにあり、各工程に入る前に全文読む。
dotfiles内で未インストールの内容を扱う場合は
`stow/design/.agents/skills/otake-visual/references/` を使う。
どちらも存在しなければ参照できないことを伝え、ユーザーの指定に沿って進める。

完成の判定は `ovs deck verify`（静的検査と描画の実測）と、保存した画像の目視の両方で行う。
既存スライドのレビュー依頼では作り直さず、`ovs deck verify` と目視の結果から指摘と修正案を出す。
図解素材を作る場合だけ `~/.agents/skills/otake-visual/SKILL.md` の生成手順も読む。
ユーザー指定のテンプレート・出力形式・デザインを優先する。
