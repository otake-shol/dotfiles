# shellcheck shell=bash
# ========================================
# ユーティリティ関数
# ========================================
# このファイルは .aliases から読み込まれる
# 純粋なエイリアスは aliases/*.zsh に定義

# ========================================
# 安全な削除
# ========================================
# rm -rf 保護機能（確認プロンプト表示）
# -r/-f/-rf/-fr およびロングオプションを検出
rm() {
  local has_recursive=false
  local has_force=false

  for arg in "$@"; do
    case "$arg" in
      -r|--recursive) has_recursive=true ;;
      -f|--force) has_force=true ;;
      -rf|-fr|-Rf|-fR|-rF|-Fr|-FR|-RF) has_recursive=true; has_force=true ;;
      # 複合オプション（-rfi, -riv等）をチェック
      -*r*) has_recursive=true ;|
      -*f*) has_force=true ;;
    esac
  done

  if [[ "$has_recursive" = true && "$has_force" = true ]]; then
    echo "WARNING: rm -rf を実行しようとしています:"
    echo "   rm $*"
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
# パス・検索
# ========================================
# パス内のコマンドを検索
pathfind() {
  local pattern="$1"
  echo "$PATH" | tr ':' '\n' | xargs -I {} find {} -name "*$pattern*" 2>/dev/null
}

# ========================================
# 圧縮・展開
# ========================================
# 圧縮ファイルを自動判定して展開
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <file>"
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "Error: '$1' is not a valid file"
    return 1
  fi

  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.tar.zst) tar --zstd -xf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.tbz2)    tar xjf "$1" ;;
    *.tgz)     tar xzf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.Z)       uncompress "$1" ;;
    *.7z)      7z x "$1" ;;
    *.rar)     unrar x "$1" ;;
    *.xz)      xz -d "$1" ;;
    *.zst)     zstd -d "$1" ;;
    *)         echo "Error: Unknown archive format '$1'" ; return 1 ;;
  esac
}
