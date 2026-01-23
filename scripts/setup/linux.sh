#!/bin/bash
# linux.sh - Linux/WSL用セットアップスクリプト
# 使用方法: bash scripts/setup/linux.sh

set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/os-detect.sh"

# ========================================
# ディストリビューション検出
# ========================================
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# WSL検出
is_wsl() {
    if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
        return 0
    fi
    return 1
}

# ========================================
# パッケージマネージャー検出
# ========================================
detect_package_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# ========================================
# パッケージインストール
# ========================================
install_packages() {
    local pkg_manager=$(detect_package_manager)

    echo -e "${YELLOW}パッケージマネージャー: $pkg_manager${NC}"

    # 基本パッケージ（共通）
    local common_packages=(
        git
        curl
        wget
        zsh
        vim
        tmux
        tree
        jq
        fzf
        unzip
        build-essential  # Debian系
    )

    case "$pkg_manager" in
        apt)
            sudo apt-get update
            sudo apt-get install -y "${common_packages[@]}" 2>/dev/null || true
            # Debian/Ubuntu固有
            sudo apt-get install -y \
                fd-find \
                ripgrep \
                bat \
                exa \
                zoxide \
                2>/dev/null || true
            # batはbatcatとしてインストールされる場合がある
            if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
                sudo ln -sf "$(which batcat)" /usr/local/bin/bat
            fi
            # fd-findはfdfindとしてインストールされる
            if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
                sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
            fi
            ;;
        dnf|yum)
            sudo $pkg_manager install -y epel-release 2>/dev/null || true
            sudo $pkg_manager install -y \
                git curl wget zsh vim tmux tree jq fzf unzip \
                fd-find ripgrep bat eza zoxide \
                2>/dev/null || true
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm \
                git curl wget zsh vim tmux tree jq fzf unzip \
                fd ripgrep bat eza zoxide \
                2>/dev/null || true
            ;;
        *)
            echo -e "${YELLOW}⚠ 未対応のパッケージマネージャーです。手動でインストールしてください${NC}"
            ;;
    esac
}

# ========================================
# Linuxbrew (Homebrew for Linux)
# ========================================
install_linuxbrew() {
    if command -v brew &>/dev/null; then
        echo -e "${GREEN}✓ Homebrew (Linuxbrew) は既にインストールされています${NC}"
        return
    fi

    echo -e "${YELLOW}Linuxbrewをインストールしますか? (y/n)${NC}"
    echo -e "${BLUE}Linuxbrewを使うと、macOSと同じBrewfileでツールを管理できます${NC}"
    read -r answer
    if [ "$answer" = "y" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # PATHに追加
        BREW_PREFIX="/home/linuxbrew/.linuxbrew"
        echo 'eval "$('$BREW_PREFIX'/bin/brew shellenv)"' >> ~/.profile
        eval "$($BREW_PREFIX/bin/brew shellenv)"

        echo -e "${GREEN}✓ Linuxbrewをインストールしました${NC}"
    fi
}

# ========================================
# Neovim (最新版)
# ========================================
install_neovim() {
    if command -v nvim &>/dev/null; then
        echo -e "${GREEN}✓ Neovimは既にインストールされています${NC}"
        return
    fi

    echo -e "${YELLOW}Neovimをインストール中...${NC}"

    local pkg_manager=$(detect_package_manager)

    case "$pkg_manager" in
        apt)
            # AppImageを使用（最新版を取得）
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x nvim.appimage
            sudo mv nvim.appimage /usr/local/bin/nvim
            ;;
        dnf|yum)
            sudo $pkg_manager install -y neovim
            ;;
        pacman)
            sudo pacman -S --noconfirm neovim
            ;;
        *)
            if command -v brew &>/dev/null; then
                brew install neovim
            fi
            ;;
    esac

    echo -e "${GREEN}✓ Neovimをインストールしました${NC}"
}

# ========================================
# モダンCLIツール（Cargo経由）
# ========================================
install_rust_tools() {
    # Rustがない場合はインストール
    if ! command -v cargo &>/dev/null; then
        echo -e "${YELLOW}Rustをインストールしますか? (モダンCLIツール用) (y/n)${NC}"
        read -r answer
        if [ "$answer" = "y" ]; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        else
            return
        fi
    fi

    echo -e "${YELLOW}Cargoでモダンツールをインストール中...${NC}"

    # パッケージマネージャーで入らなかったツールをCargoで補完
    local rust_tools=(
        "bat"
        "eza"
        "fd-find"
        "ripgrep"
        "zoxide"
        "dust"
        "procs"
        "sd"
        "hyperfine"
        "tokei"
        "git-delta"
    )

    for tool in "${rust_tools[@]}"; do
        if ! command -v "${tool%%-*}" &>/dev/null; then
            cargo install "$tool" 2>/dev/null || true
        fi
    done

    echo -e "${GREEN}✓ モダンCLIツールをインストールしました${NC}"
}

# ========================================
# WSL固有設定
# ========================================
setup_wsl() {
    if ! is_wsl; then
        return
    fi

    echo -e "${YELLOW}WSL固有設定を適用中...${NC}"

    # Windows側のクリップボード連携
    if [ -f /mnt/c/Windows/System32/clip.exe ]; then
        echo -e "${GREEN}✓ Windowsクリップボード連携が利用可能です${NC}"
    fi

    # wsl.conf設定（systemd有効化など）
    if [ ! -f /etc/wsl.conf ]; then
        echo -e "${YELLOW}wsl.confを作成しますか? (systemd有効化) (y/n)${NC}"
        read -r answer
        if [ "$answer" = "y" ]; then
            sudo tee /etc/wsl.conf > /dev/null << 'EOF'
[boot]
systemd=true

[interop]
appendWindowsPath=false

[automount]
enabled=true
options="metadata,umask=22,fmask=11"
EOF
            echo -e "${GREEN}✓ wsl.confを作成しました（WSL再起動が必要）${NC}"
        fi
    fi

    echo -e "${GREEN}✓ WSL設定が完了しました${NC}"
}

# ========================================
# Linux固有のシステム設定
# ========================================
setup_linux_defaults() {
    echo -e "${YELLOW}Linux固有設定を適用中...${NC}"

    # デフォルトシェルをzshに変更
    if [ "$(detect_shell)" != "zsh" ]; then
        echo -e "${YELLOW}デフォルトシェルをzshに変更しますか? (y/n)${NC}"
        read -r answer
        if [ "$answer" = "y" ]; then
            chsh -s "$(which zsh)"
            echo -e "${GREEN}✓ デフォルトシェルをzshに変更しました${NC}"
        fi
    fi

    # XDG Base Directory
    mkdir -p ~/.config ~/.local/share ~/.cache

    echo -e "${GREEN}✓ Linux設定が完了しました${NC}"
}

# ========================================
# メイン
# ========================================
main() {
    local distro=$(detect_distro)

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Linux セットアップスクリプト${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "ディストリビューション: $distro"
    if is_wsl; then
        echo -e "環境: WSL (Windows Subsystem for Linux)"
    fi
    echo ""

    install_packages
    install_linuxbrew
    install_neovim
    install_rust_tools
    setup_wsl
    setup_linux_defaults

    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}  Linux セットアップが完了しました${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# 直接実行された場合のみmain実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
