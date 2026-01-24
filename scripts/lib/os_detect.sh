#!/bin/bash
# os_detect.sh - OS/アーキテクチャ検出ライブラリ
# 使用方法: source scripts/lib/os_detect.sh

# OS検出
detect_os() {
    case "$(uname -s)" in
        Darwin*)  echo "macos" ;;
        Linux*)   echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# アーキテクチャ検出
detect_arch() {
    case "$(uname -m)" in
        arm64|aarch64) echo "arm64" ;;
        x86_64|amd64)  echo "amd64" ;;
        i386|i686)     echo "x86" ;;
        *)             echo "unknown" ;;
    esac
}

# Homebrew prefix検出
detect_homebrew_prefix() {
    if [ "$(detect_os)" = "macos" ]; then
        if [ "$(detect_arch)" = "arm64" ]; then
            echo "/opt/homebrew"
        else
            echo "/usr/local"
        fi
    else
        echo "/home/linuxbrew/.linuxbrew"
    fi
}

# シェル検出
detect_shell() {
    basename "$SHELL"
}

# macOSバージョン検出
detect_macos_version() {
    if [ "$(detect_os)" = "macos" ]; then
        sw_vers -productVersion
    else
        echo "N/A"
    fi
}

# システム情報表示
show_system_info() {
    echo "OS: $(detect_os)"
    echo "Arch: $(detect_arch)"
    echo "Shell: $(detect_shell)"
    if [ "$(detect_os)" = "macos" ]; then
        echo "macOS: $(detect_macos_version)"
        echo "Homebrew: $(detect_homebrew_prefix)"
    fi
}

# ========================================
# 便利な判定関数
# ========================================
is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

is_linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

is_wsl() {
    is_linux && grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null
}

is_arm64() {
    [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]]
}

# 直接実行された場合はシステム情報を表示
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_system_info
fi
