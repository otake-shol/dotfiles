# lazy.zsh - 遅延読み込み設定
# mise, atuin, fzf関数を遅延読み込みして起動を高速化

# --- mise ---
# miseはPATH直接更新でゼロオーバーヘッド
# activate結果をキャッシュして起動を高速化
if command -v mise &>/dev/null; then
  _mise_cache="${XDG_CACHE_HOME:-$HOME/.cache}/mise-init.zsh"
  if ! _cache_valid "$_mise_cache"; then
    _cache_update "$_mise_cache" "mise activate zsh"
  fi
  source "$_mise_cache"
  unset _mise_cache
fi

# 注: miseはdirenvの機能も統合しているため、direnvは不要
# .envrcの代わりに.mise.tomlの[env]セクションを使用

# --- atuin ---
if command -v atuin &>/dev/null; then
  _atuin_cache="${XDG_CACHE_HOME:-$HOME/.cache}/atuin-init.zsh"
  if ! _cache_valid "$_atuin_cache"; then
    _cache_update "$_atuin_cache" "atuin init zsh"
  fi
  source "$_atuin_cache"
  unset _atuin_cache
fi

# --- fzf拡張関数 ---
typeset -g _fzf_functions_file="${HOME}/.zsh/functions/fzf-functions.zsh"
typeset -g _fzf_funcs_loaded=false

_load_fzf_functions() {
  if [[ "$_fzf_funcs_loaded" = false ]]; then
    if [[ -f "$_fzf_functions_file" ]]; then
      source "$_fzf_functions_file" || {
        echo "Error: fzf-functions.zsh の読み込みに失敗しました" >&2
        return 1
      }
      _fzf_funcs_loaded=true
    else
      echo "Error: $_fzf_functions_file が見つかりません" >&2
      return 1
    fi
  fi
}

# fzf関数のスタブ（初回呼び出しで本体を読み込み、evalを避けて直接定義）
fbr() { _load_fzf_functions && fbr "$@"; }
fshow() { _load_fzf_functions && fshow "$@"; }
fvim() { _load_fzf_functions && fvim "$@"; }
fkill() { _load_fzf_functions && fkill "$@"; }
fcd() { _load_fzf_functions && fcd "$@"; }
fstash() { _load_fzf_functions && fstash "$@"; }
fenv() { _load_fzf_functions && fenv "$@"; }
fhistory() { _load_fzf_functions && fhistory "$@"; }
fman() { _load_fzf_functions && fman "$@"; }
fdiff() { _load_fzf_functions && fdiff "$@"; }
fgst() { _load_fzf_functions && fgst "$@"; }
