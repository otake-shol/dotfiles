# ========================================
# エディタ
# ========================================
alias nview="nvim -R"              # nvim読み取り専用モード
alias view="bat"                   # 軽量ファイル閲覧

# ========================================
# Python
# ========================================
alias python="python3"
alias pip="pip3"
alias py="python3"
alias venv="python3 -m venv"
alias activate="source .venv/bin/activate"

# ========================================
# Homebrew
# ========================================
alias brewup="brew update && brew upgrade && brew cleanup"
alias brewls="brew list"
alias brewi="brew info"
alias brews="brew search"
alias brewdeps="brew deps --tree"  # 依存関係ツリー表示

# ========================================
# HTTP
# ========================================
alias serve="python3 -m http.server 8000"  # ローカルHTTPサーバ
alias json="jq ."                          # JSON整形
alias headers="curl -I"                    # HTTPヘッダ確認
alias GET="curl -X GET"
alias POST="curl -X POST"
