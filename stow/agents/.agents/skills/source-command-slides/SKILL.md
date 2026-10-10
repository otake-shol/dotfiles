---
name: source-command-slides
description: /slides互換の入口としてcreate-story-slidesの共通手順でMarkdown・Marpスライドを構成、生成、検証する。LT・登壇・提案・計画・報告・振り返り、既存OVS資料の編集・レビュー、発表時間の見積もりに使う。編集可能なPowerPointや既存Google Slidesは専用スキルへ渡す。
---

# Markdownスライド制作

Claude Codeの `/slides` と同じ `create-story-slides` を使う。
最初に `~/.agents/skills/create-story-slides/SKILL.md` を全文読み、工程と参照先に従う。
dotfiles内の未インストールの内容は `stow/design/.agents/skills/create-story-slides/SKILL.md` を使う。
どちらも存在しなければ参照できないことを伝え、ユーザー指定に沿って進める。

構成、自己紹介、既定の出力形式、検証の規則をこの入口へ複製しない。
既存OVS資料は同スキルの `references/ovs-compatibility.md` に従う。
図解素材を生成するときだけ `otake-visual` を併用する。
