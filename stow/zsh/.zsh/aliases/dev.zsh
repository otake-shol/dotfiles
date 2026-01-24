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

# ディレクトリ作成して移動
mkcd() { mkdir -p "$1" && cd "$1"; }

# ファイル作成して編集
touchedit() { touch "$1" && nvim "$1"; }

# ポート使用プロセス検索
port() { lsof -i :"$1"; }

# クリップボードのJSONを整形
jsonf() { pbpaste | jq '.' | pbcopy && pbpaste; }

# 天気表示
weather() { curl -s "wttr.in/${1:-Tokyo}?format=3"; }

# 詳細な天気
weatherfull() { curl -s "wttr.in/${1:-Tokyo}"; }

# 一時ディレクトリで作業
tmpcd() { cd "$(mktemp -d)"; }

# base64エンコード/デコード
b64e() { echo -n "$1" | base64; }
b64d() { echo -n "$1" | base64 -d; }

# URLエンコード/デコード
urle() { python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"; }
urld() { python3 -c "import urllib.parse; print(urllib.parse.unquote('$1'))"; }

# パス内のコマンドを検索
pathfind() { echo $PATH | tr ':' '\n' | xargs -I {} find {} -name "*$1*" 2>/dev/null; }
