#!/bin/bash
# リモートコントロールで作られた claude.ai/code 側のセッションが溜まっていないか検知する。
#
# claude.ai のセッション一覧を取得・削除する API や CLI は存在しないため、
# ローカル transcript (~/.claude/projects/**/*.jsonl) に現れる bridgeSessionId を
# ユニークに数えて残数を推定する。つまり「これまでに作られた総数」であり、
# claude.ai 側で削除しても自動では減らない。掃除したら --reset を実行すること。
#
# 全走査は 3〜4 秒かかるため、前回スキャン時刻より新しい transcript だけを見る差分方式。
set -euo pipefail

readonly PROJECTS_DIR="$HOME/.claude/projects"
readonly SEEN_FILE="$HOME/.claude/.rc-seen-sessions"
readonly SCAN_MARKER="$HOME/.claude/.rc-last-scan"
readonly THRESHOLD="${CLAUDE_RC_SESSION_THRESHOLD:-20}"
readonly INITIAL_SCAN_DAYS=30

usage() {
  cat <<'EOF'
使い方: remote-session-check.sh [--reset | --status]

  (引数なし)  差分スキャンして閾値超過なら SessionStart 用の JSON を出力
  --reset     claude.ai/code 側で掃除したあとにカウンタを 0 に戻す
  --status    現在のカウントを表示（通知は出さない）

環境変数:
  CLAUDE_RC_SESSION_THRESHOLD  通知を出す閾値（デフォルト 20）
EOF
}

count_seen() {
  [[ -f "$SEEN_FILE" ]] || { echo 0; return; }
  local n
  n=$(grep -c . "$SEEN_FILE" || true)
  echo "${n:-0}"
}

# 前回スキャン以降に更新された transcript から bridgeSessionId を拾い、SEEN_FILE に蓄積する
scan() {
  local list new_ids
  list=$(mktemp)
  # shellcheck disable=SC2064
  trap "rm -f '$list'" RETURN

  if [[ -f "$SCAN_MARKER" ]]; then
    find "$PROJECTS_DIR" -name '*.jsonl' -newer "$SCAN_MARKER" -print0 >"$list" 2>/dev/null || true
  else
    # 初回は 30 日分だけ（cleanupPeriodDays のデフォルトでそれより古い transcript は消える）
    find "$PROJECTS_DIR" -name '*.jsonl' -mtime "-$INITIAL_SCAN_DAYS" -print0 >"$list" 2>/dev/null || true
  fi

  if [[ -s "$list" ]]; then
    new_ids=$(xargs -0 grep -ho '"bridgeSessionId":"[^"]*"' <"$list" 2>/dev/null |
      sed 's/.*:"//; s/"$//' || true)
    if [[ -n "$new_ids" ]]; then
      printf '%s\n' "$new_ids" >>"$SEEN_FILE"
      sort -u -o "$SEEN_FILE" "$SEEN_FILE"
    fi
  fi

  touch "$SCAN_MARKER"
}

main() {
  case "${1:-}" in
    --reset)
      : >"$SEEN_FILE"
      touch "$SCAN_MARKER"
      echo "リモートセッションのカウンタをリセットしました。"
      return 0
      ;;
    --status)
      [[ -d "$PROJECTS_DIR" ]] && scan
      echo "未整理のリモートセッション: $(count_seen) 件 / 閾値 ${THRESHOLD}"
      return 0
      ;;
    -h | --help)
      usage
      return 0
      ;;
    "") ;;
    *)
      usage >&2
      return 1
      ;;
  esac

  [[ -d "$PROJECTS_DIR" ]] || return 0
  scan

  local count
  count=$(count_seen)
  if ((count >= THRESHOLD)); then
    jq -n --arg msg "⚠ リモートコントロールのセッションが約 ${count} 件溜まっています。https://claude.ai/code のサイドバーで整理したあと \`~/.claude/hooks/remote-session-check.sh --reset\` を実行してください。" \
      '{systemMessage: $msg}'
  fi
}

main "$@"
