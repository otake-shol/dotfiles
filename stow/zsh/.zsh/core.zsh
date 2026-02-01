# core.zsh - 基本設定・オプション

# --- エディタ ---
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"

# --- manページをbatでカラー表示 ---
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# --- 実行時間の自動表示（カラー対応） ---
# preexec: コマンド実行前に時刻を記録
_cmd_start_time=""
preexec() {
  _cmd_start_time=$EPOCHSECONDS
}

# precmd: コマンド実行後に経過時間を表示
precmd() {
  if [[ -n "$_cmd_start_time" ]]; then
    local elapsed=$((EPOCHSECONDS - _cmd_start_time))
    if [[ $elapsed -ge 5 ]]; then
      local color
      if [[ $elapsed -ge 30 ]]; then
        color='\033[91m'  # 赤: 30秒以上
      elif [[ $elapsed -ge 10 ]]; then
        color='\033[93m'  # 黄: 10秒以上
      else
        color='\033[92m'  # 緑: 5秒以上
      fi
      echo -e "${color}⏱ ${elapsed}s${NC}"
    fi
  fi
  _cmd_start_time=""
}
NC='\033[0m'

# REPORTTIME は無効化（カスタム表示を使用）
# REPORTTIME=5

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
CORRECT_IGNORE='_*|claude'     # claude は遅延読み込みのため除外
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

# ========================================
# 補完強化
# ========================================
# 大文字小文字を無視（cd doc → Documents にマッチ）
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# 補完候補をメニュー表示（Tab連打で選択可能）
zstyle ':completion:*' menu select

# 補完候補に色付け（ls --colorと同じ色）
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# 補完候補をグループ化して説明表示
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

# 補完候補のキャッシュ（大規模補完の高速化）
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# killコマンドでプロセス名を補完
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# cdで親ディレクトリも補完候補に
zstyle ':completion:*' special-dirs true

# Load aliases from external file
[[ -f ~/.aliases ]] && source ~/.aliases
