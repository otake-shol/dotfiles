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

# 条件付きプラグイン - インストール済みの場合のみ読み込み
command -v docker &>/dev/null && plugins+=(docker)
command -v kubectl &>/dev/null && plugins+=(kubectl)
command -v npm &>/dev/null && plugins+=(npm)
command -v yarn &>/dev/null && plugins+=(yarn)
command -v aws &>/dev/null && plugins+=(aws)
command -v terraform &>/dev/null && plugins+=(terraform)
command -v python3 &>/dev/null && plugins+=(python)
command -v gradle &>/dev/null && plugins+=(gradle)
command -v op &>/dev/null && plugins+=(1password)
command -v jira &>/dev/null && plugins+=(jira)
command -v tig &>/dev/null && plugins+=(tig)

# web-search は常に有効
plugins+=(web-search)

# zsh-completions: 追加の補完定義を読み込み
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

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

# asdf version manager (Apple Silicon / Intel 両対応)
if [[ $(uname -m) == "arm64" ]]; then
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
else
  . /usr/local/opt/asdf/libexec/asdf.sh
fi

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
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# direnv - ディレクトリ別環境変数
eval "$(direnv hook zsh)"

# ========================================
# fzf 拡張関数
# ========================================

# fbr - ブランチをfzfで選択してチェックアウト
fbr() {
  local branches branch
  branches=$(git branch -a --color=always | grep -v HEAD) &&
  branch=$(echo "$branches" |
    fzf --ansi --preview 'git log --oneline --graph --color=always $(echo {} | sed "s/.* //" | sed "s#remotes/origin/##") -- | head -50' \
        --preview-window=right:50%) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/origin/##")
}

# fshow - コミット履歴をfzfで閲覧・詳細表示
fshow() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(green)%cr %C(blue)<%an>" |
  fzf --ansi --no-sort --reverse \
    --preview 'echo {} | grep -o "[a-f0-9]\{7,\}" | head -1 | xargs git show --color=always' \
    --preview-window=right:60% \
    --bind 'enter:execute(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1 | xargs git show --color=always | less -R)'
}

# fvim - ファイルをfzfで選択してnvimで開く
fvim() {
  local file
  file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:300 {}' \
             --preview-window=right:60%) &&
  [ -n "$file" ] && nvim "$file"
}

# fkill - プロセスをfzfで選択してkill
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf --header='Select process to kill' \
    --preview 'echo {}' --preview-window=down:3:wrap | awk '{print $2}')
  [ -n "$pid" ] && kill -9 "$pid" && echo "Killed process $pid"
}

# fcd - ディレクトリをfzfで選択して移動
fcd() {
  local dir
  dir=$(find ${1:-.} -type d 2>/dev/null | fzf --preview 'eza --tree --level=1 --color=always {}' \
        --preview-window=right:50%) &&
  cd "$dir"
}

# fstash - git stashをfzfで選択して適用
fstash() {
  local stash
  stash=$(git stash list 2>/dev/null | fzf --preview 'echo {} | cut -d: -f1 | xargs git stash show -p --color=always')
  [ -n "$stash" ] && git stash apply "$(echo "$stash" | cut -d: -f1)"
}

# fenv - 環境変数をfzfで検索
fenv() {
  local var
  var=$(env | fzf --preview 'echo {}' --preview-window=down:3:wrap)
  [ -n "$var" ] && echo "$var"
}

# fhistory - 履歴をfzfで検索して実行
fhistory() {
  local cmd
  cmd=$(history | fzf --tac --preview 'echo {}' | sed 's/^ *[0-9]* *//')
  [ -n "$cmd" ] && print -z "$cmd"
}

# fman - manページをfzfで検索
fman() {
  man -k . | fzf --preview 'echo {} | awk "{print \$1}" | xargs man' | awk '{print $1}' | xargs man
}

# zoxide - 高速ディレクトリジャンプ
eval "$(zoxide init zsh)"

# atuin - 高機能シェル履歴管理
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
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
