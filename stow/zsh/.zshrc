# ========================================
# .zshrc - メイン設定ファイル
# ========================================
# モジュール分割により保守性を向上
# 各モジュールは ~/.zsh/ に配置
#
# 構成:
#   plugins.zsh - Oh My Zsh プラグイン
#   core.zsh    - 基本設定・オプション
#   lazy.zsh    - 遅延読み込み（mise, atuin）
#   tools.zsh   - ツール設定（fzf, zoxide, yazi, bun）
#
# プロファイリング有効化（デバッグ時のみ）
# zmodload zsh/zprof

# ========================================
# Powerlevel10k instant prompt（最上部に配置必須）
# ========================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ========================================
# 環境変数（モジュール読み込み前に設定）
# ========================================
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# ========================================
# モジュール読み込み
# ========================================
ZSH_CONFIG_DIR="${HOME}/.zsh"

# Oh My Zsh プラグイン（最初に読み込む）
[[ -f "${ZSH_CONFIG_DIR}/plugins.zsh" ]] && source "${ZSH_CONFIG_DIR}/plugins.zsh"

# 基本設定・オプション
[[ -f "${ZSH_CONFIG_DIR}/core.zsh" ]] && source "${ZSH_CONFIG_DIR}/core.zsh"

# 遅延読み込み設定
[[ -f "${ZSH_CONFIG_DIR}/lazy.zsh" ]] && source "${ZSH_CONFIG_DIR}/lazy.zsh"

# ツール設定
[[ -f "${ZSH_CONFIG_DIR}/tools.zsh" ]] && source "${ZSH_CONFIG_DIR}/tools.zsh"

# ========================================
# Powerlevel10k テーマ設定
# ========================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ========================================
# ローカル設定（Git管理外）
# ========================================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ========================================
# 起動時自己診断（miseの確認）
# ========================================
_zsh_startup_check() {
  # miseがPATHに含まれているか確認
  if ! command -v mise &>/dev/null; then
    echo "⚠️  zsh: mise が見つかりません" >&2
    echo "   → brew install mise を実行してください" >&2
  fi
}
_zsh_startup_check
unset -f _zsh_startup_check

# プロファイリング結果表示（デバッグ時のみ）
# zprof
