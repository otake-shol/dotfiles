---
description: OVSテーマでMarkdownスライドを構成・生成・検証
allowed-tools: Read, Write, Glob, Bash(marp *), Bash(ovs *), Bash(mkdir *), Bash(open *)
---

# /slides - Markdownスライド制作

Codexの `source-command-slides` と同じ共通指針を使う。
最初に `~/.agents/skills/otake-visual/references/slides.md` を読む。
dotfiles内で未インストールの内容を扱う場合は
`stow/design/.agents/skills/otake-visual/references/slides.md` を使う。
どちらも存在しなければ参照できないことを伝え、ユーザーの指定に沿って進める。

共通指針に従い、構成、OVSテーマの解決、必要な形式の生成、表示の検証まで実施する。
図解素材を作る場合だけ `~/.agents/skills/otake-visual/SKILL.md` の生成手順も読む。
ユーザー指定のテンプレート・出力形式・デザインを優先する。
