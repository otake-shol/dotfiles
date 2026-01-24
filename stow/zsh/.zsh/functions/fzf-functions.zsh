# ========================================
# fzf 拡張関数
# ========================================
# このファイルは必要な時にのみ読み込まれる（lazy.zshで遅延読み込み）
# 使用方法: source ~/.zsh/functions/fzf-functions.zsh

# fbr - ブランチをfzfで選択してチェックアウト
fbr() {
  local branches branch target
  branches=$(git branch -a --color=always | grep -v HEAD) || return 1
  branch=$(echo "$branches" |
    fzf --ansi --preview 'git log --oneline --graph --color=always $(echo {} | sed "s/.* //" | sed "s#remotes/origin/##") -- | head -50' \
        --preview-window=right:50%) || return 0
  target=$(echo "$branch" | sed "s/.* //" | sed "s#remotes/origin/##")
  git checkout "$target"
}

# fshow - コミット履歴をfzfで閲覧・詳細表示
fshow() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(green)%cr %C(blue)<%an>" |
  fzf --ansi --no-sort --reverse \
    --preview 'echo {} | grep -o "[a-f0-9]\{7,\}" | head -1 | xargs git show --color=always' \
    --preview-window=right:60% \
    --bind 'enter:execute(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1 | xargs git show --color=always | less -R)'
}

# fvim - ファイルをfzfで選択してnvimで開く
fvim() {
  local file
  file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:300 {}' \
             --preview-window=right:60%) || return 0
  [[ -n "$file" ]] && nvim "$file"
}

# fkill - プロセスをfzfで選択してkill
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf --header='Select process to kill' \
    --preview 'echo {}' --preview-window=down:3:wrap | awk '{print $2}') || return 0
  [[ -n "$pid" ]] && kill -9 "$pid" && echo "Killed process $pid"
}

# fcd - ディレクトリをfzfで選択して移動
fcd() {
  local dir search_dir
  search_dir="${1:-.}"
  dir=$(find "$search_dir" -type d 2>/dev/null | fzf --preview 'eza --tree --level=1 --color=always {}' \
        --preview-window=right:50%) || return 0
  cd "$dir" || return 1
}

# fstash - git stashをfzfで選択して適用
fstash() {
  local stash stash_ref
  stash=$(git stash list 2>/dev/null | fzf --preview 'echo {} | cut -d: -f1 | xargs git stash show -p --color=always') || return 0
  [[ -n "$stash" ]] && {
    stash_ref=$(echo "$stash" | cut -d: -f1)
    git stash apply "$stash_ref"
  }
}

# fenv - 環境変数をfzfで検索
fenv() {
  local var
  var=$(env | fzf --preview 'echo {}' --preview-window=down:3:wrap) || return 0
  [[ -n "$var" ]] && echo "$var"
}

# fhistory - 履歴をfzfで検索して実行
fhistory() {
  local cmd
  cmd=$(history | fzf --tac --preview 'echo {}' | sed 's/^ *[0-9]* *//') || return 0
  [[ -n "$cmd" ]] && print -z "$cmd"
}

# fman - manページをfzfで検索
fman() {
  local page
  page=$(man -k . | fzf --preview 'echo {} | awk "{print \$1}" | xargs man' | awk '{print $1}') || return 0
  [[ -n "$page" ]] && man "$page"
}

# fdiff - 変更ファイルをfzfで選択して差分表示
fdiff() {
  local file
  file=$(git diff --name-only | fzf --preview 'git diff --color=always {}') || return 0
  [[ -n "$file" ]] && git diff "$file"
}

# fgst - git statusをfzfでインタラクティブに
fgst() {
  local selected file
  selected=$(git status -s | fzf --preview 'echo {} | awk "{print \$2}" | xargs git diff --color=always') || return 0
  [[ -n "$selected" ]] && {
    file=$(echo "$selected" | awk '{print $2}')
    nvim "$file"
  }
}
