---
name: "source-command-commit-push"
description: "現在の変更をコミットしてプッシュ"
---

# source-command-commit-push

Use this skill when the user asks to run the migrated source command `commit-push`.

## Command Template

# /commit-push - コミットしてプッシュ

現在の変更をコミットしてリモートにプッシュします。

## 手順

1. `git status` で変更内容を確認
2. `git diff` で差分を確認
3. `git log --oneline -5` で直近のコミットスタイルを確認
4. 適切なコミットメッセージを作成
5. `git add` で変更をステージング
6. `git commit` でコミット
7. `git push` でプッシュ
8. CIがある場合はプッシュしたコミットSHAの実行結果を確認する。GitHub Actionsなら `gh run list --commit <SHA>` で実行を特定し、完了まで追跡する。失敗した場合はログから原因を調べ、今回の変更に起因する問題を修正・検証して再プッシュする。実行待ちや取得不能ならCI成功と報告せず、その状態を明記する。

## コミットメッセージ規則

- 変更の「なぜ」を重視
- 簡潔に1-2文で
- 日本語OK

## 注意事項

- .env等の機密ファイルはコミットしない
- プッシュ前にブランチを確認
