# shellcheck shell=bash
# ========================================
# Claude Code セッション管理
# ========================================
# エイリアス: c, co, cs, ch, cc, cq → aliases/core.zsh

# セッション一覧表示（fzf選択で再開）
cls() {
  local projects_dir="$HOME/.claude/projects"
  local current_project
  current_project=$(echo "$PWD" | sed 's|/|-|g; s|^-||')

  # 現在のプロジェクトのセッションを取得
  local project_dir="$projects_dir/-$current_project"
  if [[ ! -d "$project_dir" ]]; then
    echo "このディレクトリのセッションはありません"
    return 1
  fi

  # セッション一覧を生成（更新日時順）
  local sessions
  sessions=$(find "$project_dir" -maxdepth 1 -name "*.jsonl" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | \
    sort -rn | \
    while read -r mtime file; do
      local session_id
      session_id=$(basename "$file" .jsonl)
      local date_str
      date_str=$(date -r "$mtime" "+%m/%d %H:%M")
      # 最初のユーザーメッセージを取得（プレビュー用）
      local preview
      preview=$(grep -m1 '"type":"user"' "$file" 2>/dev/null | jq -r '.message.content // .content // "..."' 2>/dev/null | head -c 60 | tr '\n' ' ')
      echo "$date_str | $session_id | ${preview:-...}"
    done)

  if [[ -z "$sessions" ]]; then
    echo "セッションが見つかりません"
    return 1
  fi

  # fzfで選択
  local selected
  selected=$(echo "$sessions" | fzf --height=50% --reverse --header="セッションを選択 (Enter: 再開)")

  if [[ -n "$selected" ]]; then
    local session_id
    session_id=$(echo "$selected" | awk -F' \\| ' '{print $2}' | tr -d ' ')
    claude --resume "$session_id"
  fi
}

# 全プロジェクトからセッション検索
csa() {
  local projects_dir="$HOME/.claude/projects"

  # 全セッションを取得
  local sessions
  sessions=$(find "$projects_dir" -name "*.jsonl" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | \
    sort -rn | head -50 | \
    while read -r mtime file; do
      local session_id project_name
      session_id=$(basename "$file" .jsonl)
      project_name=$(basename "$(dirname "$file")" | sed 's/^-//; s/-Users-[^-]*-//; s/-/\//g')
      local date_str
      date_str=$(date -r "$mtime" "+%m/%d %H:%M")
      local preview
      preview=$(grep -m1 '"type":"user"' "$file" 2>/dev/null | jq -r '.message.content // .content // "..."' 2>/dev/null | head -c 40 | tr '\n' ' ')
      echo "$date_str | $project_name | $session_id | ${preview:-...}"
    done)

  if [[ -z "$sessions" ]]; then
    echo "セッションが見つかりません"
    return 1
  fi

  local selected
  selected=$(echo "$sessions" | fzf --height=50% --reverse --header="全プロジェクトからセッションを選択")

  if [[ -n "$selected" ]]; then
    local session_id
    session_id=$(echo "$selected" | awk -F' \\| ' '{print $3}' | tr -d ' ')
    claude --resume "$session_id"
  fi
}
