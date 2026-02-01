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

# ========================================
# 統計・分析
# ========================================
# コマンド使用統計（トップ20）
cmdstats() {
  local num="${1:-20}"
  echo "📊 よく使うコマンド Top ${num}"
  echo "─────────────────────────────"
  fc -l 1 | awk '{CMD[$2]++} END {for (a in CMD) print CMD[a], a}' | \
    sort -rn | head -n "$num" | \
    awk '{printf "%4d  %s\n", $1, $2}'
  echo ""
  echo "💡 ヒント: 頻繁に使うコマンドはエイリアス化を検討"
}

# エイリアス使用統計
aliasstats() {
  local num="${1:-15}"
  echo "📊 エイリアス使用統計 Top ${num}"
  echo "─────────────────────────────"

  # 定義済みエイリアスを取得
  local aliases
  aliases=$(alias | cut -d'=' -f1)

  # 履歴からエイリアス使用をカウント
  fc -l 1 | awk '{print $2}' | while read -r cmd; do
    echo "$aliases" | grep -qw "$cmd" && echo "$cmd"
  done | sort | uniq -c | sort -rn | head -n "$num" | \
    awk '{printf "%4d  %s\n", $1, $2}'

  echo ""
  echo "💡 使っていないエイリアスは削除を検討"
}

# ========================================
# ファイル操作強化
# ========================================
# 最近編集したファイルをfzfで選択して開く
recent() {
  local days="${1:-7}"
  local file
  file=$(fd --type f --hidden --exclude .git --changed-within "${days}d" 2>/dev/null | \
    fzf --preview 'bat --color=always --style=numbers --line-range=:100 {}' \
        --header "最近${days}日間に編集されたファイル")
  [[ -n "$file" ]] && nvim "$file"
}

# 最近編集したファイル一覧（開かない）
recentls() {
  local days="${1:-7}"
  fd --type f --hidden --exclude .git --changed-within "${days}d" 2>/dev/null | \
    head -20 | while read -r f; do
      local mtime
      mtime=$(stat -f "%Sm" -t "%m/%d %H:%M" "$f" 2>/dev/null)
      printf "%s  %s\n" "$mtime" "$f"
    done | sort -r
}

# ========================================
# ディレクトリブックマーク
# ========================================
BOOKMARKS_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/bookmarks"

# ブックマーク追加: mark [name]
mark() {
  mkdir -p "$(dirname "$BOOKMARKS_FILE")"
  local name="${1:-$(basename "$PWD")}"
  # 既存のブックマークを削除して追加
  grep -v "^${name}|" "$BOOKMARKS_FILE" 2>/dev/null > "${BOOKMARKS_FILE}.tmp" || true
  echo "${name}|${PWD}" >> "${BOOKMARKS_FILE}.tmp"
  mv "${BOOKMARKS_FILE}.tmp" "$BOOKMARKS_FILE"
  echo "📌 ブックマーク追加: ${name} → ${PWD}"
}

# ブックマークへジャンプ: jump [name] または fzf選択
jump() {
  [[ ! -f "$BOOKMARKS_FILE" ]] && echo "ブックマークがありません" && return 1

  local name="$1"
  if [[ -z "$name" ]]; then
    # fzfで選択
    local selected
    selected=$(cat "$BOOKMARKS_FILE" | \
      awk -F'|' '{printf "%-15s %s\n", $1, $2}' | \
      fzf --header "ブックマーク選択" | \
      awk '{print $2}')
    [[ -n "$selected" ]] && cd "$selected"
  else
    # 名前で直接ジャンプ
    local path
    path=$(grep "^${name}|" "$BOOKMARKS_FILE" | cut -d'|' -f2)
    if [[ -n "$path" ]]; then
      cd "$path"
    else
      echo "ブックマーク '${name}' が見つかりません"
      return 1
    fi
  fi
}

# ブックマーク一覧
marks() {
  [[ ! -f "$BOOKMARKS_FILE" ]] && echo "ブックマークがありません" && return 1
  echo "📚 ブックマーク一覧"
  echo "─────────────────────────────"
  cat "$BOOKMARKS_FILE" | awk -F'|' '{printf "  %-15s → %s\n", $1, $2}'
}

# ブックマーク削除
unmark() {
  local name="$1"
  [[ -z "$name" ]] && echo "Usage: unmark <name>" && return 1
  grep -v "^${name}|" "$BOOKMARKS_FILE" > "${BOOKMARKS_FILE}.tmp"
  mv "${BOOKMARKS_FILE}.tmp" "$BOOKMARKS_FILE"
  echo "🗑️  ブックマーク削除: ${name}"
}

# ========================================
# クリップボード拡張
# ========================================
CLIPBOARD_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/clipboard"

# 名前付きクリップボードに保存: clip save <name>
# クリップボードから取得: clip get <name>
# 一覧表示: clip list
clip() {
  mkdir -p "$CLIPBOARD_DIR"

  case "$1" in
    save|s)
      local name="${2:-default}"
      pbpaste > "$CLIPBOARD_DIR/$name"
      echo "📋 保存: $name ($(wc -c < "$CLIPBOARD_DIR/$name" | tr -d ' ') bytes)"
      ;;
    get|g)
      local name="${2:-default}"
      if [[ -f "$CLIPBOARD_DIR/$name" ]]; then
        cat "$CLIPBOARD_DIR/$name" | pbcopy
        echo "📋 復元: $name → クリップボード"
      else
        echo "❌ '$name' が見つかりません"
        return 1
      fi
      ;;
    list|ls|l)
      echo "📋 保存済みクリップボード"
      echo "─────────────────────────────"
      for f in "$CLIPBOARD_DIR"/*; do
        [[ -f "$f" ]] || continue
        local name=$(basename "$f")
        local size=$(wc -c < "$f" | tr -d ' ')
        local preview=$(head -c 50 "$f" | tr '\n' ' ')
        printf "  %-12s %5s bytes  %s...\n" "$name" "$size" "$preview"
      done
      ;;
    delete|del|d)
      local name="${2:-default}"
      rm -f "$CLIPBOARD_DIR/$name"
      echo "🗑️  削除: $name"
      ;;
    *)
      echo "Usage: clip <save|get|list|delete> [name]"
      echo "  save <name>   - クリップボードを名前付きで保存"
      echo "  get <name>    - 保存した内容をクリップボードに復元"
      echo "  list          - 保存済み一覧"
      echo "  delete <name> - 削除"
      ;;
  esac
}

# ========================================
# 作業ログ
# ========================================
WORKLOG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/worklog"

# 作業ログ記録: wlog "やったこと"
wlog() {
  mkdir -p "$WORKLOG_DIR"
  local today=$(date +"%Y-%m-%d")
  local now=$(date +"%H:%M")
  local file="$WORKLOG_DIR/${today}.md"

  # ファイルがなければヘッダー作成
  if [[ ! -f "$file" ]]; then
    echo "# 作業ログ ${today}" > "$file"
    echo "" >> "$file"
  fi

  if [[ -n "$1" ]]; then
    echo "- ${now} $*" >> "$file"
    echo "📝 記録: $*"
  else
    # 引数なしならエディタで開く
    nvim "$file"
  fi
}

# 今日の作業ログ表示
wtoday() {
  local today=$(date +"%Y-%m-%d")
  local file="$WORKLOG_DIR/${today}.md"

  if [[ -f "$file" ]]; then
    echo "📋 今日の作業ログ (${today})"
    echo "─────────────────────────────"
    cat "$file" | tail -n +3  # ヘッダーをスキップ
  else
    echo "今日の作業ログはまだありません"
    echo "💡 wlog \"内容\" で記録を開始"
  fi
}

# 作業ログ検索
wfind() {
  local query="$1"
  if [[ -z "$query" ]]; then
    # fzfで日付選択
    local selected
    selected=$(ls -1 "$WORKLOG_DIR"/*.md 2>/dev/null | \
      xargs -I {} basename {} .md | sort -r | \
      fzf --preview "cat $WORKLOG_DIR/{}.md" --header "作業ログを選択")
    [[ -n "$selected" ]] && cat "$WORKLOG_DIR/${selected}.md"
  else
    # grepで検索
    echo "🔍 検索: ${query}"
    echo "─────────────────────────────"
    grep -r "$query" "$WORKLOG_DIR"/*.md 2>/dev/null | \
      sed "s|$WORKLOG_DIR/||g" | \
      sed 's/.md:/  /' | \
      sort -r
  fi
}

# 今週の作業サマリー
wweek() {
  echo "📊 今週の作業サマリー"
  echo "─────────────────────────────"

  local count=0
  for i in {0..6}; do
    local date=$(date -v-${i}d +"%Y-%m-%d")
    local file="$WORKLOG_DIR/${date}.md"
    if [[ -f "$file" ]]; then
      local items=$(grep -c "^- " "$file" 2>/dev/null || echo 0)
      local dow=$(date -v-${i}d +"%a")
      printf "%s (%s): %d件\n" "$date" "$dow" "$items"
      ((count += items))
    fi
  done

  echo "─────────────────────────────"
  echo "合計: ${count}件"
}

# ========================================
# バックアップ
# ========================================
BACKUP_DIR="${HOME}/Backups"

# dotfilesバックアップ
backup-dotfiles() {
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local backup_path="$BACKUP_DIR/dotfiles_${timestamp}.tar.gz"

  mkdir -p "$BACKUP_DIR"

  echo "📦 dotfilesをバックアップ中..."
  tar -czf "$backup_path" \
    -C "$HOME" \
    dotfiles \
    .zsh_history \
    .gitconfig \
    2>/dev/null

  if [[ -f "$backup_path" ]]; then
    local size=$(du -h "$backup_path" | cut -f1)
    echo "✓ バックアップ完了: $backup_path ($size)"
  else
    echo "❌ バックアップ失敗"
    return 1
  fi
}

# 重要ファイルのバックアップ
backup-important() {
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local backup_path="$BACKUP_DIR/important_${timestamp}.tar.gz"

  mkdir -p "$BACKUP_DIR"

  echo "📦 重要ファイルをバックアップ中..."

  # バックアップ対象を一時ファイルに書き出し
  local tmpfile=$(mktemp)
  cat > "$tmpfile" << 'BACKUP_LIST'
.ssh/config
.ssh/known_hosts
.gnupg
.aws/config
.kube/config
.local/share/zsh
.local/share/worklog
.local/share/atuin
BACKUP_LIST

  # 存在するファイルのみバックアップ
  local files_to_backup=""
  while IFS= read -r file; do
    [[ -e "$HOME/$file" ]] && files_to_backup+="$file "
  done < "$tmpfile"
  rm "$tmpfile"

  if [[ -n "$files_to_backup" ]]; then
    tar -czf "$backup_path" \
      -C "$HOME" \
      $files_to_backup \
      2>/dev/null

    local size=$(du -h "$backup_path" | cut -f1)
    echo "✓ バックアップ完了: $backup_path ($size)"
  else
    echo "バックアップ対象が見つかりません"
  fi
}

# バックアップ一覧
backup-list() {
  echo "📚 バックアップ一覧"
  echo "─────────────────────────────"

  if [[ -d "$BACKUP_DIR" ]]; then
    ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | \
      awk '{printf "%s  %s  %s\n", $5, $6" "$7, $NF}' | \
      sed "s|$BACKUP_DIR/||g"

    echo ""
    local total=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
    echo "合計: $total"
  else
    echo "バックアップはまだありません"
  fi
}

# 古いバックアップ削除（30日以上前）
backup-clean() {
  local days="${1:-30}"
  echo "🧹 ${days}日以上前のバックアップを削除..."

  local old_files
  old_files=$(find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$days" 2>/dev/null)

  if [[ -z "$old_files" ]]; then
    echo "削除対象はありません"
    return 0
  fi

  echo "$old_files" | while read -r f; do
    echo "  削除: $(basename "$f")"
    rm -f "$f"
  done

  echo "✓ 完了"
}

# フルバックアップ（dotfiles + 重要ファイル）
backup() {
  echo "🔄 フルバックアップ開始"
  echo ""
  backup-dotfiles
  echo ""
  backup-important
  echo ""
  echo "✅ フルバックアップ完了"
}
