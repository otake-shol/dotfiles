# ========================================
# zsh 起動速度最適化
# ========================================
# プロファイリング有効化（デバッグ時のみ）
# zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
  z
  fzf
  history
)

# 条件付きプラグイン - キャッシュを使用して高速化
# キャッシュファイル（1日有効）
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

# エディタ設定
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"

# Load aliases from external file
if [[ -f ~/.aliases ]]; then
  source ~/.aliases
fi

# History settings
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

# Zsh options
setopt no_beep
setopt auto_pushd
setopt pushd_ignore_dups
setopt auto_cd
setopt hist_ignore_dups
setopt hist_ignore_all_dups    # 重複を完全排除
setopt hist_ignore_space       # スペースで始まるコマンドを履歴に残さない
setopt hist_reduce_blanks      # 余分な空白を削除
setopt share_history
setopt inc_append_history
setopt extended_history        # タイムスタンプを記録
setopt correct                 # コマンドのスペルミスを修正
setopt complete_in_word        # 単語の途中でも補完

# Ctrl+Z でfg/bgトグル
function fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Docker (OrbStack)
# OrbStackは自動でdockerコマンドを提供するため追加設定不要

# ========================================
# asdf 遅延読み込み (起動速度最適化)
# ========================================
# 初回使用時にasdfを読み込む
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

# kiro shell integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# trash command (safe delete)
export PATH="/usr/local/opt/trash/bin:$PATH"

# Local environment
. "$HOME/.local/bin/env"

# fzf - ファジーファインダー設定
export FZF_DEFAULT_OPTS="
  --height 60%
  --layout=reverse
  --border=rounded
  --info=inline
  --preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || cat {}'
  --preview-window=right:60%:wrap
  --bind 'ctrl-/:toggle-preview'
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# ========================================
# direnv 遅延読み込み
# ========================================
# minimalモードではスキップ、それ以外は遅延読み込み
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
# fzf 拡張関数（遅延読み込み）
# ========================================
# 関数は初回呼び出し時にのみ読み込まれる
# これにより起動速度を向上
_fzf_functions_file="${DOTFILES_DIR:-$HOME/dotfiles}/zsh/functions/fzf-functions.zsh"
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

# zoxide - 高速ディレクトリジャンプ（minimalモードではスキップ）
if [[ -z "$DOTFILES_MINIMAL" ]]; then
  eval "$(zoxide init zsh)"
fi

# ========================================
# atuin 遅延読み込み
# ========================================
# minimalモードではスキップ
if [[ -z "$DOTFILES_MINIMAL" ]] && command -v atuin &>/dev/null; then
  # atuinの初期化（キャッシュを使用して高速化）
  _atuin_cache="${XDG_CACHE_HOME:-$HOME/.cache}/atuin-init.zsh"
  if [[ ! -f "$_atuin_cache" ]] || [[ $(find "$_atuin_cache" -mtime +7 2>/dev/null) ]]; then
    mkdir -p "$(dirname "$_atuin_cache")"
    atuin init zsh > "$_atuin_cache" 2>/dev/null
  fi
  source "$_atuin_cache"
  unset _atuin_cache
fi

# yazi - ターミナルファイルマネージャー
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# bun - 高速JS/TSランタイム
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# ========================================
# dotfiles更新リマインダー
# ========================================
# 30日以上更新していない場合に通知
_dotfiles_update_reminder() {
  local dotfiles_dir="$HOME/dotfiles"
  if [[ -d "$dotfiles_dir/.git" ]]; then
    local last_update=$(git -C "$dotfiles_dir" log -1 --format="%ct" 2>/dev/null)
    if [[ -n "$last_update" ]]; then
      local days_since=$(( ($(date +%s) - last_update) / 86400 ))
      if [[ $days_since -gt 30 ]]; then
        echo "⚠️  dotfilesが${days_since}日間更新されていません。'dotup'で確認してください。"
      fi
    fi
  fi
}
# 起動時にチェック（1日1回のみ）
_dotfiles_reminder_cache="$HOME/.cache/dotfiles-reminder"
if [[ ! -f "$_dotfiles_reminder_cache" ]] || [[ $(find "$_dotfiles_reminder_cache" -mtime +1 2>/dev/null) ]]; then
  _dotfiles_update_reminder
  mkdir -p "$(dirname "$_dotfiles_reminder_cache")"
  touch "$_dotfiles_reminder_cache"
fi

# ========================================
# プロファイル設定
# ========================================
# DOTFILES_PROFILE で使用するプロファイルを選択
# 利用可能: personal (default), work, minimal
DOTFILES_PROFILE="${DOTFILES_PROFILE:-personal}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

if [[ -f "$DOTFILES_DIR/profiles/${DOTFILES_PROFILE}.zsh" ]]; then
    source "$DOTFILES_DIR/profiles/${DOTFILES_PROFILE}.zsh"
fi

# ========================================
# ローカル設定（Git管理外）
# ========================================
# 環境変数・認証情報など機密情報はこちらに記述
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
