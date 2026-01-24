# ========================================
# lazy.zsh - 遅延読み込み設定
# ========================================
# asdf, atuin, direnv, fzf関数の遅延読み込み

# ========================================
# asdf 遅延読み込み
# ========================================
typeset -g _asdf_loaded=false
_asdf_init() {
  if [[ "$_asdf_loaded" = false ]]; then
    _asdf_loaded=true
    # HOMEBREW_PREFIXを使用（brew shellenvで設定済み、未設定時はアーキテクチャから推測）
    local brew_prefix="${HOMEBREW_PREFIX:-$([[ $(uname -m) == "arm64" ]] && echo /opt/homebrew || echo /usr/local)}"
    local asdf_path="${brew_prefix}/opt/asdf/libexec/asdf.sh"
    [[ -f "$asdf_path" ]] && source "$asdf_path"
  fi
}

# asdfコマンドのラッパー（遅延読み込み）
asdf() {
  _asdf_init
  command asdf "$@"
}

# node/python等使用時に自動初期化（evalを避けて直接定義）
node() { _asdf_init; unset -f node; command node "$@"; }
npm() { _asdf_init; unset -f npm; command npm "$@"; }
npx() { _asdf_init; unset -f npx; command npx "$@"; }
claude() { _asdf_init; unset -f claude; command claude "$@"; }
python3() { _asdf_init; unset -f python3; command python3 "$@"; }
pip3() { _asdf_init; unset -f pip3; command pip3 "$@"; }
ruby() { _asdf_init; unset -f ruby; command ruby "$@"; }
gem() { _asdf_init; unset -f gem; command gem "$@"; }

# ========================================
# direnv 遅延読み込み
# ========================================
if command -v direnv &>/dev/null; then
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
if command -v atuin &>/dev/null; then
  _atuin_cache="${XDG_CACHE_HOME:-$HOME/.cache}/atuin-init.zsh"
  if ! _cache_valid "$_atuin_cache"; then
    _cache_update "$_atuin_cache" "atuin init zsh"
  fi
  source "$_atuin_cache"
  unset _atuin_cache
fi

# ========================================
# fzf 拡張関数（遅延読み込み）
# ========================================
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
