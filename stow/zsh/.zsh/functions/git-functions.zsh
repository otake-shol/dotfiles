# ========================================
# Git関連関数
# ========================================
# このファイルは .aliases から読み込まれる
# エイリアスは aliases/git.zsh に定義

# Gitルートに移動
gitroot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Error: Gitリポジトリ内ではありません" >&2
    return 1
  }
  cd "$root" || return 1
}

# PRクイック作成（現在ブランチからPR）
gpr() {
  local title="$*"
  if [[ -z "$title" ]]; then
    echo "Usage: gpr <PR title>"
    return 1
  fi

  # 未プッシュならプッシュ
  if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} &>/dev/null; then
    echo "🚀 ブランチをプッシュ中..."
    git push -u origin HEAD
  fi

  gh pr create --title "$title" --fill
}

# レビュー待ちPR一覧
greview() {
  echo "📋 レビュー待ちPR"
  echo "─────────────────────────────"
  gh pr list --search "review-requested:@me" --json number,title,author,updatedAt \
    --template '{{range .}}#{{.number}} {{.title}} (by {{.author.login}}, {{timeago .updatedAt}}){{"\n"}}{{end}}'

  echo ""
  echo "📤 自分のPR"
  echo "─────────────────────────────"
  gh pr list --author "@me" --json number,title,state,updatedAt \
    --template '{{range .}}#{{.number}} [{{.state}}] {{.title}} ({{timeago .updatedAt}}){{"\n"}}{{end}}'
}

# PRをfzfで選択してチェックアウト
gprco() {
  local pr
  pr=$(gh pr list --json number,title,headRefName \
    --template '{{range .}}{{.number}}\t{{.headRefName}}\t{{.title}}{{"\n"}}{{end}}' | \
    fzf --header "PRを選択してチェックアウト" | awk '{print $1}')
  [[ -n "$pr" ]] && gh pr checkout "$pr"
}

# 今日のコミット一覧
gtoday() {
  echo "📝 今日のコミット"
  echo "─────────────────────────────"
  git log --oneline --since="midnight" --author="$(git config user.name)" 2>/dev/null || \
    echo "今日のコミットはありません"
}

# ブランチ切り替え（fzf）
gbr() {
  local branch
  branch=$(git branch -a --sort=-committerdate | \
    grep -v HEAD | \
    fzf --preview 'git log --oneline -10 {}' | \
    sed 's/^[* ]*//' | sed 's|remotes/origin/||')
  [[ -n "$branch" ]] && git checkout "$branch"
}

# コミットメッセージ検索
gfind() {
  local query="$1"
  if [[ -z "$query" ]]; then
    echo "Usage: gfind <検索ワード>"
    return 1
  fi
  git log --all --oneline --grep="$query"
}

# 差分のあるファイルをfzfで選択してadd
gadd() {
  local files
  files=$(git diff --name-only | fzf -m --preview 'git diff --color=always {}')
  [[ -n "$files" ]] && echo "$files" | xargs git add && git status -s
}
