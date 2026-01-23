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
plugins=(
  # 補完・ハイライト
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions

  # Git
  git
  github

  # 開発ツール
  docker
  kubectl
  npm
  yarn

  # ナビゲーション
  z
  fzf

  # クラウド・インフラ
  aws
  terraform

  # その他
  python
  gradle
  history
  1password
  iterm2
  jira
  tig
  web-search
)

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

# Docker Desktop
source /Users/otkshol/.docker/init-zsh.sh || true

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
# ローカル設定（Git管理外）
# ========================================
# 環境変数・認証情報など機密情報はこちらに記述
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
