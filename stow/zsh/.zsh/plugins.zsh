# ========================================
# plugins.zsh - Oh My Zsh プラグイン設定
# ========================================

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins - 条件付き読み込みで起動速度を最適化
plugins=(
  # 補完・ハイライト（必須）
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions

  # Git（必須）
  git
  github

  # ナビゲーション（必須）
  # z  # zoxideを使用するため無効化（tools.zshで設定）
  fzf
  history
)

# 条件付きプラグイン - キャッシュを使用して高速化
_plugin_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-plugin-cache"
_cache_valid=false

if [[ -f "$_plugin_cache" ]]; then
  # キャッシュが1日以内なら使用
  if [[ $(find "$_plugin_cache" -mtime -1 2>/dev/null) ]]; then
    _cache_valid=true
    source "$_plugin_cache"
  fi
fi

if [[ "$_cache_valid" = false ]]; then
  # キャッシュを再生成
  _cached_plugins=""
  (( $+commands[docker] )) && _cached_plugins+="docker "
  (( $+commands[kubectl] )) && _cached_plugins+="kubectl "
  (( $+commands[npm] )) && _cached_plugins+="npm "
  (( $+commands[yarn] )) && _cached_plugins+="yarn "
  (( $+commands[aws] )) && _cached_plugins+="aws "
  (( $+commands[terraform] )) && _cached_plugins+="terraform "
  (( $+commands[python3] )) && _cached_plugins+="python "
  (( $+commands[gradle] )) && _cached_plugins+="gradle "
  (( $+commands[op] )) && _cached_plugins+="1password "
  (( $+commands[jira] )) && _cached_plugins+="jira "
  (( $+commands[tig] )) && _cached_plugins+="tig "

  # キャッシュファイルに保存
  mkdir -p "$(dirname "$_plugin_cache")"
  echo "_cached_plugins=\"$_cached_plugins\"" > "$_plugin_cache"
fi

# キャッシュされたプラグインを追加
for p in ${=_cached_plugins}; do
  plugins+=($p)
done
unset _plugin_cache _cache_valid _cached_plugins p

# web-search は常に有効
plugins+=(web-search)

# zsh-completions: 追加の補完定義を読み込み
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# 補完キャッシュの設定（起動速度最適化）
autoload -Uz compinit
_comp_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-${ZSH_VERSION}"
if [[ -n "$_comp_cache"(#qN.mh+24) ]]; then
  # キャッシュが24時間以上古い場合のみ再生成
  compinit -d "$_comp_cache"
else
  compinit -C -d "$_comp_cache"
fi
unset _comp_cache

source $ZSH/oh-my-zsh.sh
