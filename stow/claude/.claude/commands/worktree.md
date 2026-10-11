---
description: Git ワークツリー管理
allowed-tools: Bash(git worktree *), Bash(git branch *)
---

# /worktree - ワークツリー管理

並行開発のためのgit worktree操作を支援します。

## 不要候補の診断

整理・棚卸しの依頼では `~/.agents/skills/source-command-worktree/SKILL.md` の共通手順を読み、同スキルの `scripts/diagnose.py` をPython 3で実行する。ローカルrefを使った読み取り専用診断で、削除は行わない。Orca管理分の操作は `orca-cli` スキルに従う。

## 基本操作
- 一覧: `git worktree list`
- 作成: `git worktree add ../project-feature feature/xxx`
- 削除: `git worktree remove ../project-feature`

## 推奨構成
```
~/projects/
├── my-app/           # main（プライマリ）
├── my-app-feature/   # feature/xxx
├── my-app-fix/       # fix/xxx
└── my-app-experiment/ # 実験用
```

## 並行セッション運用
各worktreeで独立したClaude Codeセッションを実行可能。
通知設定（notify.sh）でタスク完了を把握。
