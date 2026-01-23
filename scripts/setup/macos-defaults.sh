#!/bin/bash
# macos-defaults.sh - macOS固有の設定
# 使用方法: bash scripts/macos-defaults.sh

set -e

# カラー出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}macOS defaults設定を適用中...${NC}"

# ========================================
# スクリーンショット
# ========================================
# 保存先をiCloud Driveに変更
SCREENSHOT_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Contents/00_スクリーンショット"
if [ -d "$SCREENSHOT_DIR" ]; then
    defaults write com.apple.screencapture location "$SCREENSHOT_DIR"
    echo -e "${GREEN}✓ スクリーンショット保存先: $SCREENSHOT_DIR${NC}"
else
    echo -e "${YELLOW}⚠ スクリーンショット保存先ディレクトリが存在しません。スキップします${NC}"
fi

# ========================================
# ダウンロード
# ========================================
# ダウンロード先フォルダをiCloud Driveに作成（ブラウザ設定は手動で変更が必要）
DOWNLOAD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Contents/01_ダウンロード"
if [ ! -d "$DOWNLOAD_DIR" ]; then
    mkdir -p "$DOWNLOAD_DIR"
    echo -e "${GREEN}✓ ダウンロードフォルダ作成: $DOWNLOAD_DIR${NC}"
    echo -e "${YELLOW}  ※ブラウザのダウンロード先は手動で設定してください${NC}"
else
    echo -e "${GREEN}✓ ダウンロードフォルダ: $DOWNLOAD_DIR${NC}"
fi

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
# トラックパッド
# ========================================
# タップでクリック
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# 3本指ドラッグを有効化（アクセシビリティ設定）
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
echo -e "${GREEN}✓ トラックパッド: タップでクリック、3本指ドラッグ${NC}"

# ========================================
# Mission Control
# ========================================
# スペースを最近使用順に並び替えない（位置を固定）
defaults write com.apple.dock mru-spaces -bool false
# Mission Controlアニメーション高速化
defaults write com.apple.dock expose-animation-duration -float 0.1
# アプリケーションごとにウィンドウをグループ化
defaults write com.apple.dock expose-group-apps -bool true
echo -e "${GREEN}✓ Mission Control: スペース固定、高速アニメーション${NC}"

# ========================================
# Hot Corners（画面四隅のアクション）
# ========================================
# 左上: Mission Control (2)
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
# 右上: デスクトップ表示 (4)
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0
# 左下: なし (0)
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
# 右下: Launchpad (11)
defaults write com.apple.dock wvous-br-corner -int 11
defaults write com.apple.dock wvous-br-modifier -int 0
echo -e "${GREEN}✓ Hot Corners: 左上=Mission Control, 右上=デスクトップ, 右下=Launchpad${NC}"

# ========================================
# Safari（開発者向け）
# ========================================
# 開発者メニューを有効化
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
# すべてのWebページでWebインスペクタを許可
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
echo -e "${GREEN}✓ Safari: 開発者メニュー有効化${NC}"

# ========================================
# セキュリティ
# ========================================
# スクリーンセーバー解除時に即座にパスワード要求
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
echo -e "${GREEN}✓ セキュリティ: スクリーンセーバー解除時に即パスワード要求${NC}"

# ========================================
# Bluetooth（音質向上）
# ========================================
# Bluetoothヘッドフォンの音質を向上（AAC/aptX優先）
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
echo -e "${GREEN}✓ Bluetooth: ヘッドフォン音質向上${NC}"

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
echo -e "${GREEN}✓ .DS_Store: ネットワーク/USBドライブで作成しない${NC}"

# クラッシュレポートを通知センターに表示しない
defaults write com.apple.CrashReporter DialogType -string "none"

# 起動音を無効化
sudo nvram StartupMute=%01 2>/dev/null || true
echo -e "${GREEN}✓ 起動音: 無効化${NC}"

# ========================================
# 設定の反映
# ========================================
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo -e "${GREEN}✓ macOS defaults設定が完了しました${NC}"
echo -e "${YELLOW}※ 一部の設定は再起動後に反映されます${NC}"
