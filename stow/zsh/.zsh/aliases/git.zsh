# ========================================
# Git（Oh My Zsh gitプラグインの補完）
# ========================================
# 基本エイリアス(ga,gc,gp,gd,gl,gco,gb等)はOMZが提供
# ここではOMZにないものだけ定義

alias gs="git status"                    # OMZのgstと区別（短い方が好み）
alias glg="git log --graph --oneline --decorate --all"  # OMZのglgとは出力形式が異なる
alias gundo="git reset --soft HEAD^"     # OMZにない

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
# 便利なGit操作（OMZにないもの）
# ========================================
alias gamend='git commit --amend --no-edit'  # 直前コミットに追加
alias gpf='git push --force-with-lease'      # 安全なforce push

# Git関数は functions/git-functions.zsh に定義
# OMZ alias競合の解除は core.zsh で関数読み込み前に実施済み
