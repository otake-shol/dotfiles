# ========================================
# 仕事用プロファイル
# ========================================
# 使用方法: export DOTFILES_PROFILE=work を ~/.zshrc.local に追加

# 会社プロジェクトディレクトリ
export WORK_DIR="${WORK_DIR:-$HOME/Work}"

# ========================================
# 仕事用エイリアス
# ========================================
alias work="cd $WORK_DIR"
alias ws="cd $WORK_DIR"

# プロジェクト管理
alias proj="cd $WORK_DIR && ls -la"
alias today="date '+%Y-%m-%d'"

# ========================================
# VPN検出と設定
# ========================================
# VPN接続確認関数
vpn_status() {
    local vpn_name="${VPN_NAME:-VPN}"
    if command -v scutil &>/dev/null; then
        if scutil --nc list 2>/dev/null | grep -q "Connected"; then
            echo "🔒 VPN: Connected"
            return 0
        fi
    fi
    # ネットワークインターフェースで検出
    if ifconfig 2>/dev/null | grep -q "utun"; then
        echo "🔒 VPN: Connected (utun detected)"
        return 0
    fi
    echo "🔓 VPN: Disconnected"
    return 1
}

# VPN接続コマンド（会社に応じてカスタマイズ）
# 例: Cisco AnyConnect, OpenVPN, WireGuard等
# alias vpn-connect="open -a 'Cisco AnyConnect Secure Mobility Client'"
# alias vpn-disconnect="osascript -e 'tell application \"Cisco AnyConnect Secure Mobility Client\" to quit'"

# ========================================
# プロキシ設定テンプレート
# ========================================
# 会社のプロキシに合わせて ~/.zshrc.local でオーバーライド
# export HTTP_PROXY="http://proxy.company.com:8080"
# export HTTPS_PROXY="http://proxy.company.com:8080"
# export NO_PROXY="localhost,127.0.0.1,.company.com"

# プロキシ設定の切り替え関数
proxy_on() {
    local proxy_url="${1:-${COMPANY_PROXY_URL:-}}"
    if [[ -z "$proxy_url" ]]; then
        echo "Usage: proxy_on <proxy_url>"
        echo "Or set COMPANY_PROXY_URL in ~/.zshrc.local"
        return 1
    fi
    export HTTP_PROXY="$proxy_url"
    export HTTPS_PROXY="$proxy_url"
    export http_proxy="$proxy_url"
    export https_proxy="$proxy_url"
    echo "✓ Proxy enabled: $proxy_url"
}

proxy_off() {
    unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
    echo "✓ Proxy disabled"
}

proxy_status() {
    if [[ -n "${HTTP_PROXY:-}" ]]; then
        echo "🌐 Proxy: $HTTP_PROXY"
    else
        echo "🔓 Proxy: Not set"
    fi
}

# ========================================
# 企業環境用Git設定
# ========================================
# 会社のGitサーバー用設定
# git config --global url."git@github.company.com:".insteadOf "https://github.company.com/"

# コミット署名（会社で要求される場合）
# export GPG_TTY=$(tty)

# ========================================
# 企業環境用エイリアス
# ========================================
# Slack連携
# alias slack="open -a Slack"

# Teams連携
# alias teams="open -a 'Microsoft Teams'"

# Jira連携（jira-cliがインストールされている場合）
if command -v jira &>/dev/null; then
    alias jls="jira issue list --assignee=~"
    alias jmy="jira issue list --assignee=~ --status='In Progress'"
fi

# ========================================
# タイムトラッキング
# ========================================
# 作業時間記録（シンプル版）
work_start() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp: START" >> "$HOME/.work-log"
    echo "🏢 Work started at $timestamp"
}

work_end() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp: END" >> "$HOME/.work-log"
    echo "🏠 Work ended at $timestamp"
}

work_log() {
    if [[ -f "$HOME/.work-log" ]]; then
        tail -20 "$HOME/.work-log"
    else
        echo "No work log found"
    fi
}

# ========================================
# セキュリティ関連
# ========================================
# 機密情報の漏洩防止リマインダー（VERBOSEモード時のみ）
_work_security_reminder() {
    [[ "${DOTFILES_VERBOSE:-}" == "true" ]] && echo "⚠️  Work profile: Be careful with sensitive data"
}

# 初回のみ表示
if [[ -z "$_WORK_REMINDER_SHOWN" ]]; then
    _work_security_reminder
    export _WORK_REMINDER_SHOWN=1
fi

# プロファイル読み込み通知（VERBOSEモードまたは明示的に有効化時のみ）
[[ "${DOTFILES_VERBOSE:-}" == "true" ]] && echo "💼 Work profile loaded"
