# ========================================
# plugins.zsh - Oh My Zsh プラグイン設定
# ========================================

# 共通ライブラリ読み込み
[[ -f "${HOME}/.zsh/lib/cache.zsh" ]] && source "${HOME}/.zsh/lib/cache.zsh"

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

if _cache_valid "$_plugin_cache"; then
  source "$_plugin_cache"
else
  # キャッシュを再生成（Brewfileにあるツールのみ）
  _cached_plugins=""
  (( $+commands[npm] )) && _cached_plugins+="npm "
  (( $+commands[aws] )) && _cached_plugins+="aws "
  (( $+commands[python3] )) && _cached_plugins+="python "
  (( $+commands[op] )) && _cached_plugins+="1password "

  # キャッシュファイルに保存
  mkdir -p "$(dirname "$_plugin_cache")"
  echo "_cached_plugins=\"$_cached_plugins\"" > "$_plugin_cache"
fi

# キャッシュされたプラグインを追加
for p in ${=_cached_plugins}; do
  plugins+=($p)
done
unset _plugin_cache _cached_plugins p

# web-search は常に有効
plugins+=(web-search)

# zsh-completions: 追加の補完定義を読み込み
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# 補完キャッシュの設定（起動速度最適化）
# Oh My Zshと同じダンプファイルを使用してcompinit重複を防ぐ
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-${ZSH_VERSION}"
autoload -Uz compinit
if [[ -n "$ZSH_COMPDUMP"(#qN.mh+168) ]]; then
  # キャッシュが7日以上古い場合のみ再生成
  compinit -d "$ZSH_COMPDUMP"
else
  compinit -C -d "$ZSH_COMPDUMP"
fi

source $ZSH/oh-my-zsh.sh
