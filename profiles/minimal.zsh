# ========================================
# 最小構成プロファイル
# ========================================
# 使用方法: export DOTFILES_PROFILE=minimal を ~/.zshrc.local に追加
# 用途: 高速起動が必要な場合、トラブルシューティング時

# 最小限の設定のみ
# 追加のツール初期化をスキップ

# atuin/zoxide/direnvの初期化をスキップするフラグ
export DOTFILES_MINIMAL=true

echo "⚡ Minimal profile loaded (fast startup mode)"
