# ========================================
# エディタ
# ========================================

# Neovim
alias vi="nvim"
alias vim="nvim"
alias nview="nvim -R"              # nvim読み取り専用モード
alias view="bat"                   # 軽量ファイル閲覧（batに置き換え）

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
# 便利関数
# ========================================
# mkcd, touchedit, port, jsonf, tmpcd, b64e, b64d, urle, urld, pathfind
# は functions/util-functions.zsh に定義
