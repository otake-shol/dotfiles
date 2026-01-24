# ========================================
# ユーティリティ関数
# ========================================
# このファイルは .aliases から読み込まれる
# 純粋なエイリアスは aliases/*.zsh に定義

# ========================================
# 安全な削除
# ========================================
# rm -rf 保護機能（確認プロンプト表示）
rm() {
  if [[ "$*" =~ "-rf" ]] || [[ "$*" =~ "-fr" ]]; then
    echo "WARNING: rm -rf を実行しようとしています:"
    echo "   rm $@"
    echo ""
    read "confirm?本当に実行しますか？ [y/N]: "
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      command rm "$@"
    else
      echo "キャンセルしました"
      return 1
    fi
  else
    command rm -i "$@"
  fi
}

# ========================================
# ディレクトリ・ファイル操作
# ========================================
# ディレクトリ作成して移動
mkcd() {
  local dir="$1"
  mkdir -p "$dir" && cd "$dir" || return 1
}

# ファイル作成して編集
touchedit() {
  local file="$1"
  touch "$file" && nvim "$file"
}

# 一時ディレクトリで作業
tmpcd() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  cd "$tmpdir" || return 1
}

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
urle() {
  local input="$1"
  python3 -c "import urllib.parse; print(urllib.parse.quote('$input'))"
}

urld() {
  local input="$1"
  python3 -c "import urllib.parse; print(urllib.parse.unquote('$input'))"
}

# ========================================
# パス・検索
# ========================================
# パス内のコマンドを検索
pathfind() {
  local pattern="$1"
  echo "$PATH" | tr ':' '\n' | xargs -I {} find {} -name "*$pattern*" 2>/dev/null
}
