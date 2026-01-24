# ========================================
# tools.zsh - ツール設定
# ========================================
# fzf, zoxide, yazi, bun 等

# ========================================
# fzf - ファジーファインダー設定
# ========================================
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
# zoxide - 高速ディレクトリジャンプ
# ========================================
if [[ -z "$DOTFILES_MINIMAL" ]]; then
  eval "$(zoxide init zsh)"
fi

# ========================================
# yazi - ターミナルファイルマネージャー
# ========================================
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ========================================
# bun - 高速JS/TSランタイム
# ========================================
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# ========================================
# PATH設定
# ========================================
# Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# trash command (safe delete)
export PATH="/usr/local/opt/trash/bin:$PATH"

# Local environment
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# kiro shell integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# ========================================
# dotfiles更新リマインダー
# ========================================
_dotfiles_update_reminder() {
  local dotfiles_dir="$HOME/dotfiles"
  if [[ -d "$dotfiles_dir/.git" ]]; then
    local last_update=$(git -C "$dotfiles_dir" log -1 --format="%ct" 2>/dev/null)
    if [[ -n "$last_update" ]]; then
      local days_since=$(( ($(date +%s) - last_update) / 86400 ))
      if [[ $days_since -gt 30 ]]; then
        echo "dotfilesが${days_since}日間更新されていません。'dotup'で確認してください。"
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
