# ========================================
# plugins.zsh - Oh My Zsh プラグイン設定
# ========================================
# 起動速度最適化:
#   - compauditスキップ（ZSH_DISABLE_COMPFIX）
#   - compinit重複排除（DISABLE_COMPINIT + 手動1回）
#   - プラグイン最小化（atuin/zoxide/gh等で代替済みは削除）

# 共通ライブラリ読み込み
[[ -f "${HOME}/.zsh/lib/cache.zsh" ]] && source "${HOME}/.zsh/lib/cache.zsh"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# 起動速度最適化
ZSH_DISABLE_COMPFIX=true          # compauditスキップ（-200ms）
DISABLE_AUTO_UPDATE=true          # 自動更新無効（手動で omz update）
skip_global_compinit=1            # /etc/zshrcのcompinit無効化

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins - 最小構成（代替ツールがあるものは削除）
# 削除済み:
#   - history: atuinで代替
#   - github: gh CLIで代替
#   - z: zoxideで代替
#   - web-search: 使用頻度低
#   - npm/aws/python/1password: 補完定義が重い
plugins=(
  # 補完・ハイライト（必須）
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions

  # Git（必須）
  git

  # fzf キーバインド
  fzf
)

# zsh-completions: 追加の補完定義を読み込み
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# 補完キャッシュの設定
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-${ZSH_VERSION}"

# Oh My Zsh読み込み（内部でcompinitは呼ばれるがDISABLE_COMPFIXで高速化）
source $ZSH/oh-my-zsh.sh
