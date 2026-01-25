#!/bin/bash
# macos_defaults.sh - macOS開発者向け設定
# 使用方法: bash scripts/setup/macos_defaults.sh

set -uo pipefail  # -e を外してエラー時も継続

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリ読み込み
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# ヘルプ表示
show_help() {
    cat << 'EOF'
macos-defaults.sh - macOS開発者向け設定を適用

使用方法:
    bash scripts/setup/macos-defaults.sh

オプション:
    -h, --help    このヘルプを表示

設定内容:
    - Dock: 自動非表示、高速アニメーション
    - Finder: 隠しファイル表示、パスバー
    - キーボード: 高速キーリピート、自動変換無効化
    - セキュリティ: スクリーンセーバーパスワード
    - プライバシー: 広告トラッキング制限
    - DS_Store: ネットワーク/USBで作成しない
EOF
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && show_help && exit 0

echo -e "${YELLOW}macOS defaults設定を適用中...${NC}"

# ========================================
# Dock
# ========================================
# Dockを自動的に隠す
defaults write com.apple.dock autohide -bool true
# Dock表示/非表示のアニメーション速度を高速化
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
# Dockのサイズを設定
defaults write com.apple.dock tilesize -int 48
# 最近使ったアプリをDockに表示しない
defaults write com.apple.dock show-recents -bool false
echo -e "${GREEN}✓ Dock: 自動非表示、高速アニメーション${NC}"

# ========================================
# Finder
# ========================================
# 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles -bool true
# すべてのファイル拡張子を表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true
# ステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true
# 検索時にデフォルトでカレントフォルダを検索
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# 拡張子変更時の警告を無効化
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# デフォルトでリスト表示
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
echo -e "${GREEN}✓ Finder: 隠しファイル表示、パスバー、ステータスバー${NC}"

# ========================================
# キーボード
# ========================================
# キーリピート速度を高速化（vim操作に最適）
defaults write NSGlobalDomain KeyRepeat -int 2
# キーリピート開始までの時間を短縮
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# 自動大文字変換を無効化
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# スマートダッシュを無効化
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# 自動ピリオド挿入を無効化
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# スマートクォートを無効化（コード入力時に便利）
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
# スペルチェック自動修正を無効化
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
echo -e "${GREEN}✓ キーボード: 高速キーリピート、自動変換無効化${NC}"

# ========================================
# セキュリティ
# ========================================
# スクリーンセーバー解除時に即座にパスワード要求
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
echo -e "${GREEN}✓ セキュリティ: スクリーンセーバー解除時に即パスワード要求${NC}"

# ========================================
# プライバシー
# ========================================
# ターゲティング広告を制限
defaults write com.apple.AdLib forceLimitAdTracking -bool true
echo -e "${GREEN}✓ プライバシー: ターゲティング広告制限${NC}"

# ========================================
# その他
# ========================================
# .DS_Storeファイルをネットワークドライブに作成しない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
echo -e "${GREEN}✓ DS_Store: ネットワーク/USBドライブで作成しない${NC}"

# ========================================
# 設定の反映
# ========================================
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

echo -e "${GREEN}✓ macOS defaults設定が完了しました${NC}"
echo -e "${YELLOW}※ 一部の設定は再起動後に反映されます${NC}"
