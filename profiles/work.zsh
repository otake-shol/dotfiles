# ========================================
# 仕事用プロファイル
# ========================================
# 使用方法: export DOTFILES_PROFILE=work を ~/.zshrc.local に追加

# 会社プロジェクトディレクトリ
export WORK_DIR="$HOME/Work"

# 仕事用エイリアス
alias work="cd $WORK_DIR"

# VPN接続（会社に応じてカスタマイズ）
# alias vpn="open -a 'Company VPN'"

# プロキシ設定（必要に応じて）
# export HTTP_PROXY="http://proxy.company.com:8080"
# export HTTPS_PROXY="http://proxy.company.com:8080"

# 会社固有のツール
# export PATH="$HOME/company-tools/bin:$PATH"

echo "💼 Work profile loaded"
