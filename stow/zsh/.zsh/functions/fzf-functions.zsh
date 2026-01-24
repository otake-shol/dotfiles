# ========================================
# fzf 拡張関数
# ========================================
# このファイルは必要な時にのみ読み込まれる
# 使用方法: source ~/.zsh/functions/fzf-functions.zsh
# または .zshrc で autoload 設定

# fbr - ブランチをfzfで選択してチェックアウト
fbr() {
  local branches branch
  branches=$(git branch -a --color=always | grep -v HEAD) &&
  branch=$(echo "$branches" |
    fzf --ansi --preview 'git log --oneline --graph --color=always $(echo {} | sed "s/.* //" | sed "s#remotes/origin/##") -- | head -50' \
        --preview-window=right:50%) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/origin/##")
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
             --preview-window=right:60%) &&
  [ -n "$file" ] && nvim "$file"
}

# fkill - プロセスをfzfで選択してkill
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf --header='Select process to kill' \
    --preview 'echo {}' --preview-window=down:3:wrap | awk '{print $2}')
  [ -n "$pid" ] && kill -9 "$pid" && echo "Killed process $pid"
}

# fcd - ディレクトリをfzfで選択して移動
fcd() {
  local dir
  dir=$(find ${1:-.} -type d 2>/dev/null | fzf --preview 'eza --tree --level=1 --color=always {}' \
        --preview-window=right:50%) &&
  cd "$dir"
}

# fstash - git stashをfzfで選択して適用
fstash() {
  local stash
  stash=$(git stash list 2>/dev/null | fzf --preview 'echo {} | cut -d: -f1 | xargs git stash show -p --color=always')
  [ -n "$stash" ] && git stash apply "$(echo "$stash" | cut -d: -f1)"
}

# fenv - 環境変数をfzfで検索
fenv() {
  local var
  var=$(env | fzf --preview 'echo {}' --preview-window=down:3:wrap)
  [ -n "$var" ] && echo "$var"
}

# fhistory - 履歴をfzfで検索して実行
fhistory() {
  local cmd
  cmd=$(history | fzf --tac --preview 'echo {}' | sed 's/^ *[0-9]* *//')
  [ -n "$cmd" ] && print -z "$cmd"
}

# fman - manページをfzfで検索
fman() {
  man -k . | fzf --preview 'echo {} | awk "{print \$1}" | xargs man' | awk '{print $1}' | xargs man
}

# fdiff - 変更ファイルをfzfで選択して差分表示
fdiff() {
  git diff --name-only | fzf --preview 'git diff --color=always {}'
}

# fgst - git statusをfzfでインタラクティブに
fgst() {
  git status -s | fzf --preview 'echo {} | awk "{print \$2}" | xargs git diff --color=always' \
    --bind 'enter:execute(echo {} | awk "{print \$2}" | xargs nvim)'
}
