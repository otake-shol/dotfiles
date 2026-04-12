# lazy.zsh - 遅延読み込み設定
# asdf, atuin, direnv, fzf関数を遅延読み込みして起動を高速化

# --- asdf ---
typeset -g _asdf_loaded=false
_asdf_init() {
  if [[ "$_asdf_loaded" = false ]]; then
    _asdf_loaded=true
    # HOMEBREW_PREFIXを使用（brew shellenvで設定済み、未設定時はアーキテクチャから推測）
    local brew_prefix="${HOMEBREW_PREFIX:-$([[ $(uname -m) == "arm64" ]] && echo /opt/homebrew || echo /usr/local)}"
    local asdf_path="${brew_prefix}/opt/asdf/libexec/asdf.sh"
    [[ -f "$asdf_path" ]] && source "$asdf_path"
    # JAVA_HOME をasdf管理のJavaに設定（maven/gradle用）
    local java_home
    java_home="$(asdf where java 2>/dev/null)" && export JAVA_HOME="$java_home"
  fi
}

# asdfコマンドのラッパー（遅延読み込み）
asdf() {
  _asdf_init
  command asdf "$@"
}

# asdf管理ランタイム使用時に自動初期化（evalを避けて直接定義）
node() { _asdf_init; unset -f node; command node "$@"; }
npm() { _asdf_init; unset -f npm; command npm "$@"; }
npx() { _asdf_init; unset -f npx; command npx "$@"; }
claude() { _asdf_init; unset -f claude; command claude "$@"; }
python3() { _asdf_init; unset -f python3; command python3 "$@"; }
pip3() { _asdf_init; unset -f pip3; command pip3 "$@"; }
java() { _asdf_init; unset -f java; command java "$@"; }
javac() { _asdf_init; unset -f javac; command javac "$@"; }
mvn() { _asdf_init; unset -f mvn; command mvn "$@"; }
gradle() { _asdf_init; unset -f gradle; command gradle "$@"; }
gws() { _asdf_init; unset -f gws; command gws "$@"; }
vercel() { _asdf_init; unset -f vercel; command vercel "$@"; }
terraform() { _asdf_init; unset -f terraform; command terraform "$@"; }

# --- direnv ---
# hook登録は tools.zsh のキャッシュ版で一元管理（二重初期化を回避）

# --- atuin ---
if command -v atuin &>/dev/null; then
  _atuin_cache="${XDG_CACHE_HOME:-$HOME/.cache}/atuin-init.zsh"
  if ! _cache_valid "$_atuin_cache"; then
    _cache_update "$_atuin_cache" atuin init zsh
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
# 注: fbr→gbrに統合、fhistory→atuin Ctrl+Rで代替のため除外
fshow() { _load_fzf_functions && fshow "$@"; }
fvim() { _load_fzf_functions && fvim "$@"; }
fkill() { _load_fzf_functions && fkill "$@"; }
fcd() { _load_fzf_functions && fcd "$@"; }
fstash() { _load_fzf_functions && fstash "$@"; }
fenv() { _load_fzf_functions && fenv "$@"; }
fman() { _load_fzf_functions && fman "$@"; }
fdiff() { _load_fzf_functions && fdiff "$@"; }
fgst() { _load_fzf_functions && fgst "$@"; }
