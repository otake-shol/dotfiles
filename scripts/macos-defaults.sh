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
# 設定の反映
# ========================================
killall SystemUIServer 2>/dev/null || true

echo -e "${GREEN}✓ macOS defaults設定が完了しました${NC}"
