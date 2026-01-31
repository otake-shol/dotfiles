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
# gitroot関数は functions/git-functions.zsh に定義
