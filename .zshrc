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

# Plugins
plugins=(zsh-autosuggestions zsh-syntax-highlighting git z python fzf aws 1password github gradle history iterm2 jira terraform tig web-search)

source $ZSH/oh-my-zsh.sh

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

# Docker Desktop
source /Users/otkshol/.docker/init-zsh.sh || true

# asdf version manager
. /usr/local/opt/asdf/libexec/asdf.sh

# kiro shell integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Antigravity
export PATH="/Users/otkshol/.antigravity/antigravity/bin:$PATH"

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
"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# direnv - ディレクトリ別環境変数
eval "$(direnv hook zsh)"

# zoxide - 高速ディレクトリジャンプ
eval "$(zoxide init zsh)"

# yazi - ターミナルファイルマネージャー
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ========================================
# ローカル設定（Git管理外）
# ========================================
# 環境変数・認証情報など機密情報はこちらに記述
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
