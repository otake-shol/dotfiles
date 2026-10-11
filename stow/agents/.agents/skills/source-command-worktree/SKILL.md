---
name: "source-command-worktree"
description: "Git worktreeの一覧・作成・削除と不要候補の読み取り専用診断。worktreeの整理、放置した作業ディレクトリの棚卸しに使う。"
---

# source-command-worktree

並行開発のworktree管理と不要候補の診断を支援する。Orca管理下での作成・削除は `orca-cli` スキルを読み、Orcaの操作経路を使う。

## 不要候補の診断

このスキルの `scripts/diagnose.py` をPython 3で実行する。依存はGitと、使用状況の観測に使うlsof。引数省略時は現在のリポジトリを調べる。

```bash
python3 ~/.agents/skills/source-command-worktree/scripts/diagnose.py
python3 ~/.agents/skills/source-command-worktree/scripts/diagnose.py --repo ~/dotfiles
python3 ~/.agents/skills/source-command-worktree/scripts/diagnose.py --parent ~/projects --json
```

`--repo` と `--parent` は複数指定できる。親ディレクトリの直下から登録済みworktreeを列挙し、同じGit common directoryを持つリポジトリは重複排除する。全ホームを再帰探索しない。

- `review_candidate`: ローカルの基準refへマージ済みで、観測範囲に保留理由がない確認候補。
- `hold`: 変更・未追跡・ignoredファイル、使用中、Git操作中、未マージ、判定不能などの保留。
- `protected`: 主worktree、現在地を含むworktree、lockedまたはbareの保護対象。
- `prune_review`: ディレクトリが見つからない登録。マウント解除の可能性もあり、pruneの実行許可ではない。

結果は件数と対象ごとの理由を報告する。候補を「削除可能」と断定しない。基準refはローカルの `origin/HEAD`、または一意に存在する `origin/main` / `origin/master` を使う。必要なら `--base refs/remotes/origin/develop` などを指定する。fetchしないためリモートの最新状態は保証しない。squash mergeは祖先判定で検出できず、未マージとして保留する。lsofは同一ユーザーのcwdを観測するだけで、Orcaセッションの稼働・待機状態は別途確認する。

ファイル内容や秘密情報を出力しない。未追跡・ignoredファイルも保留理由に含めるため、依存ディレクトリだけが残っている場合も保留になる。submodule内部のignoredファイルは親リポジトリのstatusで検出できないため、submoduleを含むworktreeは `submodules_uninspected` で保留する。

## 診断後の整理

診断スクリプトは読み取り専用で、削除オプションを持たない。ユーザーが整理対象を選んで削除を依頼したら、実行直前に診断をやり直し、リモートのマージ状態とOrcaの利用状態も確認する。squash mergeではPRのマージ済み表示だけを根拠にせず、その後の追加コミットがないことも確かめる。

Orca管理分は `orca-cli` の削除手順に従う。通常のGit worktreeは対象を明示して `git worktree remove` を使い、`--force` や `rm -rf` へ自動で切り替えない。pruneはリポジトリ全体へ作用するため、`git worktree prune --dry-run` で対象全体を確認する。

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
各worktreeで独立したCodexセッションを実行可能。
通知設定（notify.sh）でタスク完了を把握。
