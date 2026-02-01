# shellcheck shell=bash
# ========================================
# ユーティリティ関数
# ========================================
# このファイルは .aliases から読み込まれる
# 純粋なエイリアスは aliases/*.zsh に定義

# ========================================
# 安全な削除
# ========================================
# rm -rf 保護機能（確認プロンプト表示）
# -r/-f/-rf/-fr およびロングオプションを検出
rm() {
  local has_recursive=false
  local has_force=false

  for arg in "$@"; do
    case "$arg" in
      -r|--recursive) has_recursive=true ;;
      -f|--force) has_force=true ;;
      -rf|-fr|-Rf|-fR|-rF|-Fr|-FR|-RF) has_recursive=true; has_force=true ;;
      # 複合オプション（-rfi, -riv等）をチェック
      -*r*) has_recursive=true ;|
      -*f*) has_force=true ;;
    esac
  done

  if [[ "$has_recursive" = true && "$has_force" = true ]]; then
    echo "WARNING: rm -rf を実行しようとしています:"
    echo "   rm $*"
    echo ""
    read "confirm?本当に実行しますか？ [y/N]: "
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      command rm "$@"
    else
      echo "キャンセルしました"
      return 1
    fi
  else
    command rm -i "$@"
  fi
}

# ========================================
# ディレクトリ・ファイル操作
# ========================================
# ディレクトリ作成して移動
mkcd() {
  local dir="$1"
  mkdir -p "$dir" && cd "$dir" || return 1
}

# ファイル作成して編集
touchedit() {
  local file="$1"
  touch "$file" && nvim "$file"
}

# 一時ディレクトリで作業
tmpcd() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  cd "$tmpdir" || return 1
}

# ========================================
# ネットワーク・ポート
# ========================================
# ポート使用プロセス検索
port() {
  local port_num="$1"
  lsof -i :"$port_num"
}

# ========================================
# エンコーディング・変換
# ========================================
# クリップボードのJSONを整形
jsonf() {
  pbpaste | jq '.' | pbcopy && pbpaste
}

# base64エンコード/デコード
b64e() {
  local input="$1"
  echo -n "$input" | base64
}

b64d() {
  local input="$1"
  echo -n "$input" | base64 -d
}

# URLエンコード/デコード
# 引数をsys.argvで渡すことでコマンドインジェクションを防止
urle() {
  local input="$1"
  python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$input"
}

urld() {
  local input="$1"
  python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1]))" "$input"
}

# ========================================
# パス・検索
# ========================================
# パス内のコマンドを検索
pathfind() {
  local pattern="$1"
  echo "$PATH" | tr ':' '\n' | xargs -I {} find {} -name "*$pattern*" 2>/dev/null
}

# ========================================
# 圧縮・展開
# ========================================
# 圧縮ファイルを自動判定して展開
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <file>"
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "Error: '$1' is not a valid file"
    return 1
  fi

  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.tar.zst) tar --zstd -xf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.tbz2)    tar xjf "$1" ;;
    *.tgz)     tar xzf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.Z)       uncompress "$1" ;;
    *.7z)      7z x "$1" ;;
    *.rar)     unrar x "$1" ;;
    *.xz)      xz -d "$1" ;;
    *.zst)     zstd -d "$1" ;;
    *)         echo "Error: Unknown archive format '$1'" ; return 1 ;;
  esac
}

# ========================================
# Claude Code セッション管理
# ========================================
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

# セッション削除（古いセッションをクリーンアップ）
csd() {
  local days="${1:-30}"
  local projects_dir="$HOME/.claude/projects"

  echo "🔍 ${days}日以上前のセッションを検索中..."

  local old_sessions
  old_sessions=$(find "$projects_dir" -name "*.jsonl" -type f -mtime +"$days" 2>/dev/null)
  local count
  count=$(echo "$old_sessions" | grep -c "." 2>/dev/null || echo 0)

  if [[ "$count" -eq 0 ]]; then
    echo "✓ ${days}日以上前のセッションはありません"
    return 0
  fi

  local total_size
  total_size=$(echo "$old_sessions" | xargs du -ch 2>/dev/null | tail -1 | awk '{print $1}')

  echo "📁 ${count}個のセッション (${total_size}) が見つかりました"
  echo ""
  read "confirm?削除しますか？ [y/N]: "

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "$old_sessions" | xargs rm -f
    # 空のディレクトリも削除
    find "$projects_dir" -type d -empty -delete 2>/dev/null
    echo "✓ 削除完了"
  else
    echo "キャンセルしました"
  fi
}

# クイック続行（最新セッションを再開）
cc() {
  claude --continue
}

# モデル指定で起動
cm() {
  local model="${1:-sonnet}"
  shift 2>/dev/null
  claude --model "$model" "$@"
}

# クイック質問（パイプ対応）
# 使い方: cq "質問" または echo "質問" | cq
cq() {
  if [[ -n "$1" ]]; then
    claude --print "$1"
  elif [[ ! -t 0 ]]; then
    # 標準入力から読み込み
    local input
    input=$(cat)
    claude --print "$input"
  else
    echo "Usage: cq '質問' or echo '質問' | cq"
    return 1
  fi
}

# git diffをClaudeに送信してレビュー依頼
cgd() {
  local diff
  diff=$(git diff --staged 2>/dev/null)
  if [[ -z "$diff" ]]; then
    diff=$(git diff 2>/dev/null)
  fi

  if [[ -z "$diff" ]]; then
    echo "差分がありません"
    return 1
  fi

  echo "$diff" | claude --print "以下のdiffをレビューしてください。問題点や改善提案があれば教えてください：

\`\`\`diff
$(cat)
\`\`\`"
}

# 現在のエラーログをClaudeに送信
cel() {
  local log="${1:-20}"
  local error_log
  error_log=$(tail -n "$log" /var/log/system.log 2>/dev/null || journalctl -n "$log" 2>/dev/null || echo "ログを取得できません")
  echo "$error_log" | claude --print "以下のログを分析して、エラーや問題があれば説明してください：

\`\`\`
$(cat)
\`\`\`"
}
