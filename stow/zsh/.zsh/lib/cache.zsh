# ========================================
# cache.zsh - キャッシュユーティリティ
# ========================================
# 各モジュールで使用するキャッシュ機能を統一管理
#
# 使用例:
#   if ! _cache_valid "$cache_file"; then
#     _cache_update "$cache_file" "zoxide init zsh"
#   fi
#   source "$cache_file"

# キャッシュが有効かチェック
# Usage: _cache_valid "$cache_file" && source "$cache_file"
# Returns: 0 if valid, 1 if invalid or not exists
_cache_valid() {
  local cache_file="$1"
  local ttl_sec=$(( ${DOTFILES_CACHE_TTL_DAYS:-7} * 86400 ))

  [[ ! -f "$cache_file" ]] && return 1

  local mtime
  if [[ "$(uname)" == "Darwin" ]]; then
    mtime=$(stat -f %m "$cache_file" 2>/dev/null)
  else
    mtime=$(stat -c %Y "$cache_file" 2>/dev/null)
  fi

  [[ -n "$mtime" && $(( $(date +%s) - mtime )) -lt $ttl_sec ]]
}

# キャッシュを更新（コマンド出力を保存）
# Usage: _cache_update "$cache_file" "command init zsh"
_cache_update() {
  local cache_file="$1"
  shift
  mkdir -p "$(dirname "$cache_file")"
  eval "$@" > "$cache_file" 2>/dev/null
}

# キャッシュファイルをタッチ（更新日時のみ更新）
# Usage: _cache_touch "$cache_file"
_cache_touch() {
  local cache_file="$1"
  mkdir -p "$(dirname "$cache_file")"
  touch "$cache_file"
}
