#!/bin/bash
# pam-watchid.sh - Apple Watch で sudo 認証を可能にする PAM モジュールのセットアップ
# 使用方法: bash scripts/setup/pam-watchid.sh
#
# 前提:
#   - macOS 10.15 以降
#   - Xcode Command Line Tools（swiftc が必要）
#   - Apple Watch のペアリング済み
#
# 参考: https://github.com/biscuitehh/pam-watchid

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリ読み込み
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

PAM_MODULE="/usr/local/lib/pam/pam_watchid.so"
PAM_SUDO_LOCAL="/etc/pam.d/sudo_local"
REPO_URL="https://github.com/biscuitehh/pam-watchid.git"
BUILD_DIR="/tmp/pam-watchid-build"

# ========================================
# チェック
# ========================================

# macOS 専用
if ! is_macos; then
    echo -e "${RED}このスクリプトは macOS 専用です${NC}"
    exit 1
fi

# swiftc の確認
if ! command -v swiftc &>/dev/null; then
    echo -e "${RED}swiftc が見つかりません${NC}"
    echo -e "${YELLOW}Xcode Command Line Tools をインストールしてください:${NC}"
    echo -e "  xcode-select --install"
    exit 1
fi

# ========================================
# インストール
# ========================================

echo -e "${YELLOW}Apple Watch sudo 認証（pam-watchid）セットアップ${NC}"

# 1. PAM モジュールのビルド・インストール
if [ -f "$PAM_MODULE" ]; then
    echo -e "${GREEN}✓ pam_watchid.so はインストール済みです${NC}"
else
    echo -e "${YELLOW}pam-watchid をビルドします...${NC}"

    # クリーンビルド
    rm -rf "$BUILD_DIR"
    git clone --depth=1 "$REPO_URL" "$BUILD_DIR"

    if ! make -C "$BUILD_DIR" 2>/dev/null; then
        echo -e "${RED}ビルドに失敗しました${NC}"
        rm -rf "$BUILD_DIR"
        exit 1
    fi

    echo -e "${YELLOW}pam_watchid.so をインストールします（sudo が必要）${NC}"
    if ! sudo mkdir -p "$(dirname "$PAM_MODULE")" || \
       ! sudo cp "$BUILD_DIR/pam_watchid.so" "$PAM_MODULE" || \
       ! sudo chmod 444 "$PAM_MODULE"; then
        echo -e "${RED}✗ pam_watchid.so のインストールに失敗しました${NC}"
        rm -rf "$BUILD_DIR"
        exit 1
    fi

    rm -rf "$BUILD_DIR"
    echo -e "${GREEN}✓ pam_watchid.so をインストールしました${NC}"
fi

# 2. sudo_local の設定
# macOS Sonoma 以降は sudo_local が推奨（OS アップデートで上書きされない）
setup_sudo_local() {
    local watchid_line='auth       sufficient     pam_watchid.so "reason=execute a command as root"'
    local touchid_line='auth       sufficient     pam_tid.so'

    if [ -f "$PAM_SUDO_LOCAL" ]; then
        if grep -q "pam_watchid" "$PAM_SUDO_LOCAL"; then
            echo -e "${GREEN}✓ sudo_local に pam_watchid は設定済みです${NC}"
            return 0
        fi
        echo -e "${YELLOW}sudo_local に pam_watchid を追加します（sudo が必要）${NC}"
        if ! echo "$watchid_line" | sudo tee -a "$PAM_SUDO_LOCAL" >/dev/null; then
            echo -e "${RED}✗ sudo_local の更新に失敗しました${NC}"
            return 1
        fi
        echo -e "${GREEN}✓ pam_watchid を sudo_local に追加しました${NC}"
    else
        echo -e "${YELLOW}sudo_local を作成します（sudo が必要）${NC}"
        local content="# sudo_local: ローカル認証設定（OS アップデートで上書きされない）
${watchid_line}
${touchid_line}"
        if ! echo "$content" | sudo tee "$PAM_SUDO_LOCAL" >/dev/null; then
            echo -e "${RED}✗ sudo_local の作成に失敗しました${NC}"
            return 1
        fi
        echo -e "${GREEN}✓ sudo_local を作成しました（Apple Watch + Touch ID 対応）${NC}"
    fi
}

if ! setup_sudo_local; then
    exit 1
fi

# ========================================
# 検証
# ========================================
echo ""
echo -e "${BLUE}現在の sudo 認証設定:${NC}"
cat "$PAM_SUDO_LOCAL"

echo ""
echo -e "${GREEN}セットアップ完了！${NC}"
echo -e "${YELLOW}動作確認:${NC}"
echo -e "  sudo -k && sudo echo 'Apple Watch 認証成功'"
echo -e ""
echo -e "${YELLOW}注意:${NC}"
echo -e "  • Apple Watch を装着しロック解除した状態で使用してください"
echo -e "  • システム設定 → Touch ID とパスコード → Apple Watch も有効にしてください"
