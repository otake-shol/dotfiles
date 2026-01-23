#!/bin/bash
# ========================================
# migrate-to-chezmoi.sh - chezmoi移行スクリプト
# ========================================
# 現在のdotfilesからchezmoiへの移行を支援
#
# 使用方法: bash scripts/setup/migrate-to-chezmoi.sh [OPTIONS]
#
# Options:
#   --dry-run    変更をプレビュー（実行しない）
#   --help       ヘルプを表示

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="${SCRIPT_DIR}/../.."
DRY_RUN=false

# 色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

show_help() {
    cat << 'EOF'
chezmoi Migration Script

Usage: bash migrate-to-chezmoi.sh [OPTIONS]

Options:
  --dry-run    Preview changes without applying
  --help       Show this help message

This script helps migrate from the current dotfiles setup to chezmoi.

Steps performed:
  1. Check prerequisites (chezmoi installed)
  2. Initialize chezmoi source directory
  3. Add managed files
  4. Create templates for multi-machine configs
  5. Verify migration

EOF
}

# 引数処理
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# chezmoiの確認
check_chezmoi() {
    log_step "chezmoiの確認"

    if command -v chezmoi &>/dev/null; then
        log_info "chezmoi $(chezmoi --version) がインストールされています"
    else
        log_warn "chezmoiがインストールされていません"
        echo ""
        echo "インストール方法:"
        echo "  brew install chezmoi"
        echo "  または"
        echo "  sh -c \"\$(curl -fsLS get.chezmoi.io)\""
        exit 1
    fi
}

# chezmoi初期化
init_chezmoi() {
    log_step "chezmoiの初期化"

    if [[ -d "$HOME/.local/share/chezmoi" ]]; then
        log_warn "chezmoiは既に初期化されています"
        log_info "既存の設定を使用します"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] chezmoi init --source $DOTFILES_ROOT"
    else
        chezmoi init --source "$DOTFILES_ROOT"
        log_info "chezmoiを初期化しました"
    fi
}

# ファイルの追加
add_files() {
    log_step "管理対象ファイルの追加"

    local files=(
        "$HOME/.zshrc"
        "$HOME/.aliases"
        "$HOME/.editorconfig"
        "$HOME/.tool-versions"
    )

    local dirs=(
        "$HOME/.config/nvim"
        "$HOME/.config/ghostty"
    )

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "[DRY-RUN] chezmoi add $file"
            else
                chezmoi add "$file" 2>/dev/null || log_warn "スキップ: $file"
            fi
        fi
    done

    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "[DRY-RUN] chezmoi add $dir"
            else
                chezmoi add "$dir" 2>/dev/null || log_warn "スキップ: $dir"
            fi
        fi
    done
}

# テンプレート変換
create_templates() {
    log_step "テンプレートの作成"

    log_info "以下のファイルをテンプレート化することを推奨:"
    echo "  - .zshrc (プロファイル、パス設定)"
    echo "  - .gitconfig (ユーザー情報)"
    echo ""
    echo "テンプレート化する方法:"
    echo "  chezmoi edit --apply ~/.zshrc"
    echo ""
    echo "テンプレート構文の例:"
    echo "  {{ .chezmoi.username }}"
    echo "  {{ if eq .chezmoi.os \"darwin\" }}macOS{{ end }}"
}

# 検証
verify_migration() {
    log_step "移行の検証"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] chezmoi diff"
        return
    fi

    echo ""
    log_info "管理対象ファイル:"
    chezmoi managed | head -20

    echo ""
    log_info "差分確認:"
    chezmoi diff --no-pager | head -50 || true

    echo ""
    log_info "ステータス:"
    chezmoi status
}

# 次のステップを表示
show_next_steps() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  次のステップ${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo "1. テンプレートを編集:"
    echo "   chezmoi edit ~/.zshrc"
    echo ""
    echo "2. 変更を適用:"
    echo "   chezmoi apply"
    echo ""
    echo "3. 新しいマシンでセットアップ:"
    echo "   chezmoi init --apply https://github.com/otake-shol/dotfiles.git"
    echo ""
    echo "ドキュメント: docs/setup/CHEZMOI-MIGRATION.md"
}

# メイン
main() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  chezmoi 移行スクリプト${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "ドライランモード - 変更は適用されません"
        echo ""
    fi

    check_chezmoi
    init_chezmoi
    add_files
    create_templates
    verify_migration
    show_next_steps

    echo ""
    log_info "移行準備が完了しました"
}

main "$@"
