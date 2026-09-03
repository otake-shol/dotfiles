---
description: PC健康診断
allowed-tools: Bash(*)
---

# /pc-checkup - PC健康診断

PCの動作が重い時に原因を特定し、対応案を提示します。

## 診断手順

### 1. システム状態の確認
```bash
top -l 1 -n 0 | head -10
```
- Load Average
- CPU使用率（idle%）
- メモリ使用量（PhysMem）
- スワップ状況

### 2. 負荷の高いプロセスを特定
```bash
ps -Ao pid,rss,comm -m | head -20
```
- メモリ消費量順に表示
- 異常に高いプロセスを特定

### 3. 使用中のポートを確認（開発サーバー等）
```bash
lsof -i -P | grep LISTEN | head -20
```

### 4. Codex Computer Use ゾンビプロセスの確認
```bash
~/dotfiles/bin/cleanup-codex-zombies
```
- Codex.app の Computer Use Agent (kernel.js) はセッション終了後も子プロセスが正しくkillされず残留することがある
- fd（ファイルディスクリプタ）を掴んだまま数十日単位で残り、「Too many open files」の原因になる
- 1日以上残留しているものが出たら `~/dotfiles/bin/cleanup-codex-zombies --kill` で終了してよい（正常なセッションが誤検知されることはまず無い）

### 5. Claude Code のディスク使用量
```bash
du -sh ~/.claude/* 2>/dev/null | sort -rh | head -8
find ~/.claude/projects -name '*.jsonl' -mtime +30 -exec du -ch {} + 2>/dev/null | tail -1
find ~/.claude/cache -name '*.tmp.*' | wc -l
```
- `projects/` が支配的（セッションのトランスクリプト）。数百MB〜GB規模になる
- `file-history/` は編集ファイルの復元履歴
- `cache/*.tmp.*` は statusline の書き込みが中断された残骸（下記参照）

## 診断結果の出力フォーマット

```
## 診断結果

| 項目 | 状態 | 詳細 |
|------|------|------|
| CPU | ✅/⚠️ | Load Avg, idle% |
| メモリ | ✅/⚠️ | 使用量/空き |
| ディスク | ✅/⚠️ | 空き容量 |

## 負荷の原因（上位5件）

| プロセス | メモリ | CPU | 対応 |
|----------|--------|-----|------|
| xxx | xxxMB | xx% | 停止推奨/様子見 |

## 対応案

1. **即効性あり**
   - [対応内容と実行コマンド]

2. **検討推奨**
   - [対応内容と実行コマンド]
```

## よくある対応案

### Codex Computer Use ゾンビプロセスの終了
```bash
~/dotfiles/bin/cleanup-codex-zombies --kill
```

### 開発サーバーの停止
```bash
lsof -i :ポート番号 -t | xargs kill
```

### npmキャッシュクリア
```bash
npm cache clean --force
# または
pnpm store prune
```

### 不要なDockerリソース削除
```bash
docker system prune -f
```

### Claude Code のディスク掃除

削除の影響が小さい順に並べている。上2つは確認不要、下2つは必ずユーザーに確認する。

**1. 孤児 tmp ファイル（影響なし）**

statusline は更新が重なると実行中にキャンセルされる仕様のため、`tmp` へ書いて `mv` する途中で止まった残骸が少しずつ溜まる。
```bash
find ~/.claude/cache -name '*.tmp.*' -mtime +1 -delete
```

**2. statusline のディレクトリ別キャッシュ（影響なし）**

`statusline-git<パス>.env` は訪問したディレクトリごとに1ファイル増える。削除しても次回訪問時に再生成される。
```bash
find ~/.claude/cache -name 'statusline-git*.env' -mtime +7 -delete
```
- `usage-notify-state.env` は**消さない**（使用量通知の抑制状態。消すと通知が再送される）
- `statusline-batt.env` も消さなくてよい（1ファイル固定）

**3. 古いセッショントランスクリプト（⚠️ 要確認・容量の本命）**
```bash
# 先に対象量を確認してからユーザーに提示する
find ~/.claude/projects -name '*.jsonl' -mtime +30 -exec du -ch {} + 2>/dev/null | tail -1
# 削除
find ~/.claude/projects -name '*.jsonl' -mtime +30 -delete
```
⚠️ 削除したセッションは `/resume` で復帰できなくなり、会話履歴の検索対象からも消える。日数は用途に応じて調整する（迷うなら +90）。

**4. file-history（⚠️ 要確認）**
```bash
find ~/.claude/file-history -type f -mtime +30 -delete
find ~/.claude/file-history -type d -empty -delete
```
⚠️ Claude が編集したファイルの復元履歴。ロールバックが不要になった期間ぶんだけ消す。

### メモリ圧迫時
- 不要なブラウザタブを閉じる
- 使っていないアプリを終了
- 複数起動しているClaude CLIセッションを終了

## 注意事項

- 対応を実行する前にユーザーに確認を取る
- 強制終了（kill -9）は最終手段
- 重要なプロセスを誤って停止しないよう注意
