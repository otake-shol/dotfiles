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

# ========================================
# npm
# ========================================
alias ni="npm install"
alias nid="npm install --save-dev"
alias nig="npm install -g"
alias nr="npm run"
alias ns="npm start"
alias nt="npm test"
alias nci="npm ci"                     # クリーンインストール
alias nout="npm outdated"              # 更新可能なパッケージ確認
alias nup="npm update"                 # パッケージ更新

# ========================================
# yarn
# ========================================
alias yi="yarn install"
alias ya="yarn add"
alias yad="yarn add --dev"
alias yr="yarn run"
alias ys="yarn start"
alias yt="yarn test"
alias yup="yarn upgrade-interactive"   # インタラクティブ更新

# ========================================
# pnpm
# ========================================
alias pn="pnpm"
alias pni="pnpm install"
alias pna="pnpm add"
alias pnad="pnpm add -D"
alias pnr="pnpm run"
alias pnx="pnpm dlx"
alias pnup="pnpm update --interactive" # インタラクティブ更新
