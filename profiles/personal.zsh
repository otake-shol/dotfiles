# ========================================
# 個人開発用プロファイル
# ========================================
# 使用方法: DOTFILES_PROFILE=personal を設定（デフォルト）

# 個人プロジェクトディレクトリ
export PROJECTS_DIR="$HOME/Projects"

# 個人用エイリアス
alias proj="cd $PROJECTS_DIR"

# 個人用Git設定（必要に応じて）
# git config --global user.email "personal@example.com"

echo "🏠 Personal profile loaded"
