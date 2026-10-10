---
description: create-story-slidesの共通手順でMarkdown（Marp）スライドを構成・生成・検証する。LT・登壇・提案・計画・報告・振り返り、既存OVS資料の編集・レビュー、発表時間の見積もりに使う
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(marp *), Bash(ovs *), Bash(node *), Bash(mkdir *), Bash(open *)
---

# /slides - Markdownスライド制作

Codexの `source-command-slides` と同じ `create-story-slides` を使う。
最初に `~/.agents/skills/create-story-slides/SKILL.md` を全文読み、工程と参照先に従う。
dotfiles内の未インストールの内容は `stow/design/.agents/skills/create-story-slides/SKILL.md` を使う。
どちらも存在しなければ参照できないことを伝え、ユーザー指定に沿って進める。

構成、自己紹介、既定の出力形式、検証の規則をこの入口へ複製しない。
既存OVS資料は同スキルの `references/ovs-compatibility.md` に従う。
図解素材を生成するときだけ `~/.agents/skills/otake-visual/SKILL.md` を併用する。

このコマンドの許可範囲で `build.sh` を呼べない場合は、正本の `review.md` と
`marp-output.md` に従って同じテーマの `ovs deck verify`、`marp` のPDF・ノート出力を直接実行する。
