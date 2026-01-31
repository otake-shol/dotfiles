# tools.zsh - ツール設定（fzf, zoxide, yazi, bun）

# --- fzf ---
# 注: Ctrl+Rはatuinがオーバーライドするためfzfのキーバインドは無効
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

# --- zoxide ---
# --cmd cd: cdコマンドをzoxideに置き換え（公式推奨オプション）
# 使い方: cd foo（スマートジャンプ）, cdi foo（fzf選択）, builtin cd（純粋なcd）
if command -v zoxide &>/dev/null; then
  _zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zoxide-init-cd.zsh"
  if ! _cache_valid "$_zoxide_cache"; then
    _cache_update "$_zoxide_cache" "zoxide init zsh --cmd cd"
  fi
  source "$_zoxide_cache"
  unset _zoxide_cache
fi

# --- yazi ---
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# --- bun ---
export BUN_INSTALL="$HOME/.bun"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# --- PATH ---
# bun
[[ -d "$BUN_INSTALL/bin" ]] && export PATH="$BUN_INSTALL/bin:$PATH"

# Antigravity
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# trash command (safe delete)
_trash_path="${HOMEBREW_PREFIX:-/usr/local}/opt/trash/bin"
[[ -d "$_trash_path" ]] && export PATH="$_trash_path:$PATH"
unset _trash_path

# Local environment
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"


# --- dotfiles更新リマインダー（macOS専用） ---
_dotfiles_update_reminder() {
  local dotfiles_dir="$HOME/dotfiles"
  local git_head="$dotfiles_dir/.git/refs/heads/master"
  # masterがなければmainを試す
  [[ -f "$git_head" ]] || git_head="$dotfiles_dir/.git/refs/heads/main"

  if [[ -f "$git_head" ]]; then
    # ファイルのmtimeを取得（git logより高速）
    local last_update
    last_update=$(stat -f %m "$git_head" 2>/dev/null)

    if [[ -n "$last_update" ]]; then
      local days_since=$(( ($(date +%s) - last_update) / 86400 ))
      if [[ $days_since -gt 30 ]]; then
        echo "dotfilesが${days_since}日間更新されていません。'dotup'で確認してください。"
      fi
    fi
  fi
}

# 起動時にチェック（キャッシュTTL期間ごと）
_dotfiles_reminder_cache="$HOME/.cache/dotfiles-reminder"
if ! _cache_valid "$_dotfiles_reminder_cache"; then
  _dotfiles_update_reminder
  _cache_touch "$_dotfiles_reminder_cache"
fi
unset _dotfiles_reminder_cache
