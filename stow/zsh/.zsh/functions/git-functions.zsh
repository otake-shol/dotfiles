# ========================================
# Git関連関数
# ========================================
# このファイルは .aliases から読み込まれる
# エイリアスは aliases/git.zsh に定義

# Gitルートに移動
gitroot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Error: Gitリポジトリ内ではありません" >&2
    return 1
  }
  cd "$root" || return 1
}
