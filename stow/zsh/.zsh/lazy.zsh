# ========================================
# lazy.zsh - 遅延読み込み設定
# ========================================
# asdf, atuin, direnv, fzf関数の遅延読み込み

# ========================================
# asdf 遅延読み込み
# ========================================
_asdf_loaded=false
_asdf_init() {
  if [[ "$_asdf_loaded" = false ]]; then
    _asdf_loaded=true
    if [[ $(uname -m) == "arm64" ]]; then
      . /opt/homebrew/opt/asdf/libexec/asdf.sh
    else
      . /usr/local/opt/asdf/libexec/asdf.sh
    fi
  fi
}

# asdfコマンドのラッパー（遅延読み込み）
asdf() {
  _asdf_init
  command asdf "$@"
}

# node/python等使用時に自動初期化
for cmd in node npm npx python python3 pip pip3 ruby gem; do
  eval "$cmd() { _asdf_init; unset -f $cmd; command $cmd \"\$@\"; }"
done

# ========================================
# direnv 遅延読み込み
# ========================================
if [[ -z "$DOTFILES_MINIMAL" ]] && command -v direnv &>/dev/null; then
  _direnv_hook() {
    trap -- '' SIGINT
    eval "$(direnv export zsh 2>/dev/null)"
    trap - SIGINT
  }
  typeset -ag precmd_functions
  if (( ! ${precmd_functions[(I)_direnv_hook]} )); then
    precmd_functions=(_direnv_hook $precmd_functions)
  fi
  typeset -ag chpwd_functions
  if (( ! ${chpwd_functions[(I)_direnv_hook]} )); then
    chpwd_functions=(_direnv_hook $chpwd_functions)
  fi
fi

# ========================================
# atuin 遅延読み込み
# ========================================
if [[ -z "$DOTFILES_MINIMAL" ]] && command -v atuin &>/dev/null; then
  _atuin_cache="${XDG_CACHE_HOME:-$HOME/.cache}/atuin-init.zsh"
  if [[ ! -f "$_atuin_cache" ]] || [[ $(find "$_atuin_cache" -mtime +7 2>/dev/null) ]]; then
    mkdir -p "$(dirname "$_atuin_cache")"
    atuin init zsh > "$_atuin_cache" 2>/dev/null
  fi
  source "$_atuin_cache"
  unset _atuin_cache
fi

# ========================================
# fzf 拡張関数（遅延読み込み）
# ========================================
_fzf_functions_file="${HOME}/.zsh/functions/fzf-functions.zsh"
_fzf_funcs_loaded=false

_load_fzf_functions() {
  if [[ "$_fzf_funcs_loaded" = false ]] && [[ -f "$_fzf_functions_file" ]]; then
    source "$_fzf_functions_file"
    _fzf_funcs_loaded=true
  fi
}

# fzf関数のスタブ（初回呼び出しで本体を読み込み）
for _fn in fbr fshow fvim fkill fcd fstash fenv fhistory fman fdiff fgst; do
  eval "$_fn() { _load_fzf_functions; $_fn \"\$@\"; }"
done
unset _fn
