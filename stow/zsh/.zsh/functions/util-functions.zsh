# shellcheck shell=bash
# ========================================
# ユーティリティ関数
# ========================================
# このファイルは .aliases から読み込まれる
# 純粋なエイリアスは aliases/*.zsh に定義

# ========================================
# ディレクトリ・ファイル操作
# ========================================
# ディレクトリ作成して移動
mkcd() {
  local dir="$1"
  mkdir -p "$dir" && cd "$dir" || return 1
}

# ファイル内容をクリップボードにコピー
cpfile() { cat "$1" | pbcopy && echo "Copied: $1"; }

# ========================================
# ネットワーク・ポート
# ========================================
# ポート使用プロセス検索
port() {
  local port_num="$1"
  lsof -i :"$port_num"
}

# ========================================
# エンコーディング・変換
# ========================================
# クリップボードのJSONを整形
jsonf() {
  pbpaste | jq '.' | pbcopy && pbpaste
}

# base64エンコード/デコード
b64e() {
  local input="$1"
  echo -n "$input" | base64
}

b64d() {
  local input="$1"
  echo -n "$input" | base64 -d
}

# URLエンコード/デコード
# 引数をsys.argvで渡すことでコマンドインジェクションを防止
urle() {
  local input="$1"
  python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$input"
}

urld() {
  local input="$1"
  python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1]))" "$input"
}

# ========================================
# ファイル操作強化
# ========================================
# 最近編集したファイルをfzfで選択して開く
recent() {
  local days="${1:-7}"
  local file
  file=$(fd --type f --hidden --exclude .git --changed-within "${days}d" 2>/dev/null | \
    fzf --preview 'bat --color=always --style=numbers --line-range=:100 {}' \
        --header "最近${days}日間に編集されたファイル")
  [[ -n "$file" ]] && nvim "$file"
}

