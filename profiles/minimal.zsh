# ========================================
# 最小構成プロファイル
# ========================================
# 使用方法: export DOTFILES_PROFILE=minimal を ~/.zshrc.local に追加
# 用途: 高速起動が必要な場合、トラブルシューティング時、CI/CD環境

# ========================================
# 最適化フラグ
# ========================================
# 重いツールの初期化をスキップ
export DOTFILES_MINIMAL=true

# 以下のツールの初期化がスキップされる:
# - atuin (シェル履歴)
# - zoxide (ディレクトリジャンプ)
# - direnv (環境変数管理)

# ========================================
# 最小限のプラグイン設定
# ========================================
# zshrcでプラグインキャッシュを無効化
export ZSH_DISABLE_PLUGIN_CACHE=true

# ========================================
# エイリアス上書き（minimalモード用）
# ========================================
# eza ではなく標準 ls を使用（軽量化）
alias l="ls -la"

# git log は最新10件に制限（出力抑制）
alias gl="git log --oneline -10"

# ========================================
# デバッグ用関数
# ========================================
# zsh起動時間の計測
zsh_time() {
    for i in $(seq 1 5); do
        /usr/bin/time zsh -i -c exit 2>&1
    done
}

# プロファイリング有効化ガイド
zsh_profile() {
    echo "To profile zsh startup:"
    echo "1. Add 'zmodload zsh/zprof' to top of ~/.zshrc"
    echo "2. Add 'zprof' at the end of ~/.zshrc"
    echo "3. Start new shell and check output"
}

# 読み込まれた関数の一覧
zsh_functions() {
    print -l ${(ok)functions}
}

# 読み込まれたエイリアスの一覧
zsh_aliases() {
    alias
}

# ========================================
# トラブルシューティング用
# ========================================
# zsh設定のリセット（一時的）
zsh_vanilla() {
    echo "Starting vanilla zsh (no config)..."
    env -i HOME="$HOME" TERM="$TERM" zsh --no-rcs
}

# 特定のzshrcで起動
zsh_with() {
    local config="${1:-}"
    if [[ -z "$config" ]]; then
        echo "Usage: zsh_with <path_to_zshrc>"
        return 1
    fi
    ZDOTDIR="$(dirname "$config")" zsh
}

# ========================================
# CI/CD環境用
# ========================================
# 非対話モードの検出
if [[ ! -o interactive ]]; then
    # 非対話モードでは追加の最適化
    unsetopt PROMPT_SUBST
fi

# CI環境の検出
if [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]] || [[ -n "${GITLAB_CI:-}" ]]; then
    # CI環境では最小限の設定
    export TERM="${TERM:-dumb}"
    # 色を無効化（ログ出力用）
    export NO_COLOR=1
fi

# ========================================
# 通常プロファイルへの切り替え
# ========================================
# 一時的に通常モードに切り替える
use_full_profile() {
    echo "Switching to full profile..."
    unset DOTFILES_MINIMAL
    source ~/.zshrc
}

# ========================================
# ベンチマーク
# ========================================
# 起動時間比較
compare_startup() {
    echo "=== Minimal mode ==="
    for i in 1 2 3; do
        DOTFILES_PROFILE=minimal /usr/bin/time -p zsh -i -c exit 2>&1 | grep real
    done
    echo ""
    echo "=== Normal mode ==="
    for i in 1 2 3; do
        DOTFILES_PROFILE=personal /usr/bin/time -p zsh -i -c exit 2>&1 | grep real
    done
}

# プロファイル読み込み通知（VERBOSEモードまたは明示的に有効化時のみ）
[[ "${DOTFILES_VERBOSE:-}" == "true" ]] && echo "⚡ Minimal profile loaded (fast startup mode)"
