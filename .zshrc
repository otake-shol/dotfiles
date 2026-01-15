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

# Zsh options
setopt no_beep
setopt auto_pushd
setopt pushd_ignore_dups
setopt auto_cd
setopt hist_ignore_dups
setopt share_history
setopt inc_append_history

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
