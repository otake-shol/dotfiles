# ========================================
# Git
# ========================================
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gd="git diff"
alias gl="git log"
alias glg="git log --graph --oneline --decorate --all"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gba="git branch -a"
alias gf="git fetch"
alias gm="git merge"
alias grb="git rebase"
alias gst="git stash"
alias gsta="git stash apply"
alias gundo="git reset --soft HEAD^"

# ========================================
# GitHub CLI (gh)
# ========================================
alias ghc="gh repo clone"              # リポジトリクローン
alias ghw="gh repo view --web"         # ブラウザで開く
alias gha="gh auth status"             # 認証状態確認
alias ghpr="gh pr create"              # PR作成
alias ghpv="gh pr view --web"          # PRをブラウザで開く
alias ghpl="gh pr list"                # PR一覧
alias ghic="gh issue create"           # Issue作成
alias ghil="gh issue list"             # Issue一覧
alias ghiv="gh issue view --web"       # Issueをブラウザで開く
alias ghr="gh run list"                # Workflow実行一覧
alias ghrw="gh run watch"              # Workflow実行を監視
alias ghd="gh dash"                    # PRダッシュボード

# ========================================
# lazygit（Git TUI）
# ========================================
alias lg="lazygit"                     # Git TUI起動

# ========================================
# 便利なGit操作
# ========================================
alias gwip='git add -A && git commit -m "WIP: work in progress"'  # WIPコミット
alias gunwip='git log -1 --format="%s" | grep -q "^WIP:" && git reset HEAD~1'  # WIP取消
alias gclean='git branch --merged | grep -v "\*\|main\|master" | xargs -n 1 git branch -d'  # マージ済みブランチ削除
alias gamend='git commit --amend --no-edit'  # 直前コミットに追加
alias gpf='git push --force-with-lease'      # 安全なforce push

# ========================================
# 便利なGit関数
# ========================================

# oh-my-zshプラグインとの競合を回避
unalias gpr gbr 2>/dev/null

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
