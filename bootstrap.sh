#!/bin/bash
# bootstrap.sh - 新しいMacの自動セットアップスクリプト
#
# Usage:
#   bash bootstrap.sh           # 通常実行
#   bash bootstrap.sh -n        # ドライラン
#   bash bootstrap.sh -y        # 完全自動（対話なし）
#   bash bootstrap.sh -n -v     # ドライラン + 詳細出力
#
# Options:
#   -n, --dry-run      シミュレーション実行
#   -y, --yes          対話プロンプトを自動応答
#   -v, --verbose      詳細出力
#   --skip-apps         Brewfile全体をスキップ（最小CLI依存のみ導入）
#   --skip-gui-apps     --skip-apps の別名
#   --cli-only          Brewfile から GUI cask を除外して導入
#   --no-codex-desktop  Codex Desktop DMG のインストールを行わない
#   --with-codex-desktop Codex Desktop DMG を明示的に導入（-y と併用時の opt-in）
#
# Codex Desktop の挙動:
#   対話モード（-y なし）: 確認プロンプト
#   -y モード         : デフォルトでスキップ、--with-codex-desktop で明示導入

set -euo pipefail

# ========================================
# 設定・初期化
# ========================================
DRY_RUN=false
VERBOSE=false
SKIP_APPS=false
ASSUME_YES=false
CLI_ONLY=false
NO_CODEX_DESKTOP=false
WITH_CODEX_DESKTOP=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_STEP=""
# パッケージごとの除外は stow/<pkg>/.stow-local-ignore に分離。
# CLI --ignore は basename 末尾マッチのため、ここではsafety netとして basename のみ指定。
STOW_IGNORE_FLAGS=(
    "--ignore=\\.p10k\\.zsh\$"
    "--ignore=installation_id\$"
)

# Zshプラグインバージョン（更新時はここを変更）
POWERLEVEL10K_TAG="v1.20.0"
ZSH_AUTOSUGGESTIONS_TAG="v0.7.1"
ZSH_SYNTAX_HIGHLIGHTING_TAG="0.8.0"
ZSH_COMPLETIONS_TAG="0.35.0"

# 色定義
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

# Homebrew prefix（Apple Silicon / Intel）
detect_homebrew_prefix() {
    [[ "$(uname -m)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local"
}

brew_command() {
    if command -v brew >/dev/null 2>&1; then
        command -v brew
        return 0
    fi

    local prefix
    prefix="$(detect_homebrew_prefix)"
    if [ -x "$prefix/bin/brew" ]; then
        echo "$prefix/bin/brew"
        return 0
    fi

    for prefix in /opt/homebrew /usr/local; do
        if [ -x "$prefix/bin/brew" ]; then
            echo "$prefix/bin/brew"
            return 0
        fi
    done

    return 1
}

load_homebrew_env() {
    local brew_bin
    if brew_bin="$(brew_command)"; then
        eval "$("$brew_bin" shellenv)" 2>/dev/null || true
    fi
}

ensure_minimal_cli_tools() {
    local brew_bin
    brew_bin="$(brew_command)" || {
        echo -e "${RED}Homebrewが必要です${NC}"
        exit 1
    }

    if ! command -v stow >/dev/null 2>&1; then
        echo -e "${CYAN}最小CLI依存をインストール: stow${NC}"
        "$brew_bin" install stow
    fi
}

# ========================================
# 引数解析
# ========================================
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--dry-run)   DRY_RUN=true ;;
        -y|--yes)       ASSUME_YES=true ;;
        -v|--verbose)   VERBOSE=true ;;
        --skip-apps|--skip-gui-apps) SKIP_APPS=true ;;
        --cli-only)     CLI_ONLY=true ;;
        --no-codex-desktop) NO_CODEX_DESKTOP=true ;;
        --with-codex-desktop) WITH_CODEX_DESKTOP=true ;;
        -h|--help)
            sed -n '2,22p' "$0" | sed 's/^# \?//'
            exit 0 ;;
        *) echo -e "${RED}不明なオプション: $1${NC}"; exit 1 ;;
    esac
    shift
done

# ========================================
# ユーティリティ関数
# ========================================
show_step() {
    CURRENT_STEP="[$1/$2] $3"
    echo -e "\n${YELLOW}${CURRENT_STEP}${NC}"
}

ask() {
    [[ "$ASSUME_YES" = true ]] && return 0
    echo -e "${YELLOW}$1 (y/n)${NC}"
    read -r answer
    [[ "$answer" = "y" ]]
}

dry_run_msg() {
    echo -e "${CYAN}[DRY RUN] $*${NC}"
}

install_codex_desktop() {
    local app_path="/Applications/Codex.app"
    local arch dmg_url tmp_dir dmg_path mount_point

    if [ -d "$app_path" ]; then
        echo -e "  ${GREEN}✓${NC} Codex Desktop"
        return 0
    fi

    arch="$(uname -m)"
    case "$arch" in
        arm64)  dmg_url="https://persistent.oaistatic.com/codex-app-prod/Codex.dmg" ;;
        x86_64) dmg_url="https://persistent.oaistatic.com/codex-app-prod/Codex-latest-x64.dmg" ;;
        *)      echo -e "  ${YELLOW}⚠${NC} Codex Desktop 未対応アーキテクチャ: $arch"; return 0 ;;
    esac

    tmp_dir="$(mktemp -d)"
    dmg_path="$tmp_dir/Codex.dmg"

    curl -fsSL "$dmg_url" -o "$dmg_path"
    mount_point="$(hdiutil attach "$dmg_path" -nobrowse | awk -F'\t' '/\/Volumes\// {print $NF; exit}')"
    if [ -z "$mount_point" ] || [ ! -d "$mount_point/Codex.app" ]; then
        echo -e "  ${YELLOW}⚠${NC} Codex Desktop DMGのマウントに失敗しました"
        [ -n "$mount_point" ] && hdiutil detach "$mount_point" >/dev/null 2>&1 || true
        rm -rf "$tmp_dir"
        return 1
    fi

    cp -R "$mount_point/Codex.app" /Applications/
    hdiutil detach "$mount_point" >/dev/null
    rm -rf "$tmp_dir"
    echo -e "  ${GREEN}✓${NC} Codex Desktop"
}

# Zshプラグイン冪等インストール（タグ指定で再現性確保）
ensure_zsh_plugin() {
    local name="$1" repo_url="$2" dest="$3" tag="${4:-}"
    if [ -d "$dest/.git" ]; then
        # タグ指定時は固定バージョンを維持（pullしない）
        if [ -n "$tag" ]; then
            echo -e "  ${GREEN}✓${NC} $name (${tag})"
        else
            git -C "$dest" pull --quiet 2>/dev/null && echo -e "  ${GREEN}✓${NC} $name" || echo -e "  ${YELLOW}⚠${NC} $name"
        fi
    else
        [ -d "$dest" ] && rm -rf "$dest"
        if [ -n "$tag" ]; then
            git clone --depth=1 --branch "$tag" "$repo_url" "$dest" 2>/dev/null
        else
            git clone --depth=1 "$repo_url" "$dest" 2>/dev/null
        fi
        echo -e "  ${GREEN}✓${NC} $name"
    fi
}

# エラー時のクリーンアップ
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "\n${RED}エラー発生${NC} (code: $exit_code, step: ${CURRENT_STEP:-初期化中})"
    fi
}
trap cleanup EXIT

# ========================================
# 前提チェック
# ========================================
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}macOS専用です${NC}"; exit 1
fi

for cmd in git curl; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}${cmd} が見つかりません → xcode-select --install${NC}"; exit 1
    fi
done

echo -e "${CYAN}dotfiles セットアップ${NC}"
[[ "$DRY_RUN" = true ]] && echo -e "${CYAN}[ドライランモード]${NC}"

# ========================================
# 1. Homebrew
# ========================================
show_step 1 6 "Homebrewの確認"
if [ "$DRY_RUN" = true ]; then
    if brew_command >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Homebrewはインストール済み${NC}"
    else
        dry_run_msg "Homebrewをインストールします"
    fi
elif ! brew_command >/dev/null 2>&1; then
    if ask "Homebrewをインストールしますか?"; then
        # 公式インストーラのみ例外的に直接実行する。安全方針はREADMEの「セキュリティ」を参照。
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        load_homebrew_env
        echo -e "${GREEN}✓ Homebrewをインストールしました${NC}"
    else
        echo -e "${RED}Homebrewが必要です${NC}"; exit 1
    fi
else
    echo -e "${GREEN}✓ Homebrewはインストール済み${NC}"
    load_homebrew_env
fi

# ========================================
# 2. アプリケーション
# ========================================
show_step 2 6 "アプリケーションのインストール"
if [ "$SKIP_APPS" = true ]; then
    if [ "$DRY_RUN" = true ]; then
        dry_run_msg "Brewfile全体はスキップし、最小CLI依存(stow)のみ確認します"
    else
        ensure_minimal_cli_tools
    fi
    echo -e "${CYAN}Brewfile全体のインストールはスキップ${NC}"
elif [ "$DRY_RUN" = true ]; then
    if [ -f "$SCRIPT_DIR/Brewfile" ]; then
        dry_run_msg "brew bundle --file=$SCRIPT_DIR/Brewfile --no-upgrade"
        if brew_bin="$(brew_command)"; then
            "$brew_bin" bundle check --file="$SCRIPT_DIR/Brewfile" --no-upgrade 2>/dev/null || true
        fi
    else
        echo -e "${RED}Brewfileが見つかりません${NC}"; exit 1
    fi
elif [ -f "$SCRIPT_DIR/Brewfile" ]; then
    BUNDLE_ARGS=(--file="$SCRIPT_DIR/Brewfile" --no-upgrade)
    [[ "$VERBOSE" = true ]] && BUNDLE_ARGS+=(--verbose)
    [[ "$CLI_ONLY" = true ]] && BUNDLE_ARGS+=(--no-cask)
    if ! brew bundle "${BUNDLE_ARGS[@]}"; then
        echo -e "${YELLOW}⚠ 一部パッケージのインストールに失敗しました${NC}"
        ask "失敗がありますが続行しますか?" || exit 1
    fi
    if [ "$NO_CODEX_DESKTOP" = true ] || [ "$CLI_ONLY" = true ]; then
        :
    elif [ "$WITH_CODEX_DESKTOP" = true ]; then
        install_codex_desktop
    elif [ "$ASSUME_YES" = true ]; then
        echo -e "${CYAN}Codex Desktop はスキップ（明示導入は --with-codex-desktop）${NC}"
    elif ask "Codex Desktopをインストールしますか?"; then
        install_codex_desktop
    fi
else
    echo -e "${RED}Brewfileが見つかりません${NC}"; exit 1
fi

# ========================================
# 3. dotfiles シンボリックリンク (GNU Stow)
# ========================================
show_step 3 6 "dotfilesのシンボリックリンク作成"

STOW_AVAILABLE=true
if ! command -v stow &>/dev/null; then
    STOW_AVAILABLE=false
    if [ "$DRY_RUN" = true ]; then
        dry_run_msg "GNU StowをHomebrewでインストールします"
    else
        echo -e "${RED}GNU Stowがインストールされていません${NC}"; exit 1
    fi
fi

read -r -a STOW_PACKAGES <<< "$(make -C "$SCRIPT_DIR" -s packages)"
for pkg in "${STOW_PACKAGES[@]}"; do
    if [ ! -d "$SCRIPT_DIR/stow/$pkg" ]; then
        echo -e "${YELLOW}⚠ $pkg が見つかりません${NC}"; continue
    fi
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}[DRY RUN] $pkg${NC}"
        if [ "$STOW_AVAILABLE" = true ]; then
            stow "${STOW_IGNORE_FLAGS[@]}" --simulate -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow "$pkg" 2>&1 || true
        else
            dry_run_msg "stow --simulate -v --target=$HOME --dir=$SCRIPT_DIR/stow --restow $pkg"
        fi
    else
        # --adopt: 初回のみ使用（HOMEの既存ファイルをstow/に取り込んで競合解消）
        # 2回目以降は--restowのみ（意図しないファイル取り込みを防止）
        if stow "${STOW_IGNORE_FLAGS[@]}" -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow "$pkg" 2>/dev/null; then
            :
        elif ask "  $pkg で競合が発生。--adopt で既存ファイルを取り込みますか?"; then
            stow "${STOW_IGNORE_FLAGS[@]}" -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow --adopt "$pkg"
            echo -e "  ${YELLOW}⚠ git diff で取り込まれたファイルを確認してください${NC}"
        fi
    fi
done
echo -e "${GREEN}✓ Stowパッケージ完了 (${STOW_PACKAGES[*]})${NC}"

# SSH ディレクトリ
if [ "$DRY_RUN" != true ]; then
    mkdir -p ~/.ssh/sockets && chmod 700 ~/.ssh
fi

# ========================================
# 4. Oh My Zsh + プラグイン
# ========================================
show_step 4 6 "Oh My Zshのセットアップ"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if [ "$DRY_RUN" = true ] || [ "${CI:-}" = "true" ]; then
        echo -e "${CYAN}[DRY RUN/CI] スキップ${NC}"
    elif ask "Oh My Zshをインストールしますか?"; then
        # 公式インストーラのみ例外的に直接実行する。安全方針はREADMEの「セキュリティ」を参照。
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo -e "${GREEN}✓ Oh My Zsh${NC}"
    fi
else
    echo -e "${GREEN}✓ Oh My Zshはインストール済み${NC}"
fi

if [ -d "$HOME/.oh-my-zsh" ] && [ "$DRY_RUN" != true ] && [ "${CI:-}" != "true" ]; then
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    ensure_zsh_plugin "powerlevel10k" "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k" "$POWERLEVEL10K_TAG"
    ensure_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions" "$ZSH_AUTOSUGGESTIONS_TAG"
    ensure_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" "$ZSH_SYNTAX_HIGHLIGHTING_TAG"
    ensure_zsh_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions" "$ZSH_CUSTOM/plugins/zsh-completions" "$ZSH_COMPLETIONS_TAG"
    echo -e "${GREEN}✓ プラグイン完了${NC}"
fi

# ========================================
# 5. 追加設定
# ========================================
show_step 5 6 "追加設定"

if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}[DRY RUN] macOS defaults・追加設定をスキップ${NC}"
else
    # --- macOS defaults（初回のみ適用、再適用は make macos-defaults） ---
    MACOS_DEFAULTS_MARKER="$HOME/.dotfiles-macos-defaults-applied"
    if [ ! -f "$MACOS_DEFAULTS_MARKER" ]; then
        bash "$SCRIPT_DIR/bin/apply-macos-defaults"
        touch "$MACOS_DEFAULTS_MARKER"
    else
        echo -e "${CYAN}macOS defaults 適用済み（再適用は 'make macos-defaults'）${NC}"
    fi

    # --- git-secrets ---
    if command -v git-secrets &>/dev/null; then
        git secrets --install ~/.git-templates/git-secrets 2>/dev/null || true
        git secrets --register-aws --global 2>/dev/null || true
        echo -e "${GREEN}✓ git-secrets${NC}"
    fi

    # --- Neovim TokyoNight ---
    TOKYONIGHT_DIR="$HOME/.local/share/nvim/site/pack/colors/start/tokyonight.nvim"
    if [ ! -d "$TOKYONIGHT_DIR" ]; then
        mkdir -p "$(dirname "$TOKYONIGHT_DIR")"
        git clone --depth=1 https://github.com/folke/tokyonight.nvim "$TOKYONIGHT_DIR"
        echo -e "${GREEN}✓ Neovim TokyoNight${NC}"
    fi

    # --- bat テーマキャッシュ構築（テーマ自体はStowで展開済み） ---
    bat cache --build 2>/dev/null || true
fi

# --- ローカル設定ファイル ---
if [ ! -f ~/.gitconfig.local ]; then
    if [ "$DRY_RUN" = true ]; then
        dry_run_msg "$HOME/.gitconfig.local を作成します"
    else
        cp "$SCRIPT_DIR/templates/gitconfig.local.template" ~/.gitconfig.local
        if [ "$ASSUME_YES" = true ]; then
            echo -e "${GREEN}✓ ~/.gitconfig.local（要編集）${NC}"
        else
            echo -e "${YELLOW}Git ユーザー情報を設定します（空Enterで雛形のまま）${NC}"
            read -rp "ユーザー名: " git_name
            read -rp "メールアドレス: " git_email
            [ -n "$git_name" ]  && sed -i '' "s|name = Your Name|name = $git_name|" ~/.gitconfig.local
            [ -n "$git_email" ] && sed -i '' "s|email = your.email@example.com|email = $git_email|" ~/.gitconfig.local
            echo -e "${GREEN}✓ ~/.gitconfig.local${NC}"
        fi
    fi
fi

if [ ! -f ~/.zshrc.local ]; then
    if [ "$DRY_RUN" = true ]; then
        dry_run_msg "$HOME/.zshrc.local を作成します"
    else
        cp "$SCRIPT_DIR/templates/zshrc.local.template" ~/.zshrc.local 2>/dev/null || true
        echo -e "${GREEN}✓ ~/.zshrc.local${NC}"
    fi
fi

# ========================================
# 6. Claude Code（オプション）
# ========================================
show_step 6 6 "Claude Codeのセットアップ"

add_mcp_server() {
    local name="$1"; shift
    local out exit_code
    out="$(claude mcp add "$name" --scope user "$@" 2>&1)" && exit_code=0 || exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} ${name}"
    elif printf '%s' "$out" | grep -qiE 'already (exists|configured|added)'; then
        echo -e "  ${GREEN}✓${NC} ${name} (既存)"
    else
        echo -e "  ${YELLOW}⚠${NC} ${name}: $(printf '%s' "$out" | head -1)"
    fi
}

if command -v claude &>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}[DRY RUN] MCPサーバー・プラグイン設定をスキップ${NC}"
    elif ask "Claude Code MCPサーバーを設定しますか?"; then
        add_mcp_server context7    -- npx -y @upstash/context7-mcp@latest
        add_mcp_server playwright  -- npx -y @playwright/mcp@latest
        add_mcp_server github      --transport http https://api.githubcopilot.com/mcp/
        add_mcp_server hourei      -- npx -y hourei-mcp-server
        add_mcp_server tax-law     -- npx -y tax-law-mcp
        add_mcp_server mf-ca       --transport http https://beta.mcp.developers.biz.moneyforward.com/mcp/ca/v3
        if command -v gws &>/dev/null; then
            add_mcp_server gws     -- gws mcp -s all
        fi

        # プラグイン
        claude /plugin marketplace add obra/superpowers-marketplace 2>/dev/null || true
        claude /plugin install superpowers@superpowers-marketplace 2>/dev/null || true
        echo -e "${GREEN}✓ プラグイン${NC}"
    fi
else
    echo -e "${CYAN}スキップ（Claude Code未インストール）${NC}"
fi

# ========================================
# 完了
# ========================================
echo -e "\n${GREEN}セットアップ完了！${NC}"
echo -e "  1. ターミナルを再起動（または ${CYAN}exec zsh${NC}）"
echo -e "  2. Powerlevel10kカスタマイズ: ${CYAN}p10k configure${NC}"
echo -e "  3. asdfランタイム導入: ${CYAN}make runtimes-install${NC}（必要な場合のみ）"
